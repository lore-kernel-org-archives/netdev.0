From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add support for filtering neigh dump by
 master device
Date: Fri, 2 Oct 2015 13:51:15 -0600
Message-ID: <560EE033.3040300@cumulusnetworks.com>
References: <1443544323-13242-1-git-send-email-dsa@cumulusnetworks.com>
 <87h9m9tchw.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34870 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751296AbbJBTvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 15:51:17 -0400
Received: by pacfv12 with SMTP id fv12so116995207pac.2
        for <netdev@vger.kernel.org>; Fri, 02 Oct 2015 12:51:17 -0700 (PDT)
In-Reply-To: <87h9m9tchw.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/2/15 11:18 AM, Eric W. Biederman wrote:
> What is the thinking here because it sure looks like you are busily
> adding layer two functionality you swore you did not want.

Interfaces are enslaved to a VRF device, but neighbor entries are 
installed with a reference to the actual interface not the VRF device.

This patch (plus the iproute2 one) fills a gap for usability and 
debugging. I have one more patch to go and then I will send an update to 
the documentation, but here is a preview (documentation update has more 
detail via examples):

Using iproute2 for VRFs
1. Create a VRF
    ip link add dev NAME type vrf table ID

2. List VRFs
    ip [-d] link show type vrf
    --> -d is needed to show table id

3. Assign a Network Interface to a VRF
    ip link set dev NAME master VRF-NAME

4. Show Devices Assigned to a VRF
    ip [-br] link show master VRF-NAME

5. Show Neighbor Entries for a VRF
    ip [-6] neigh show master VRF-NAME

    (This patch is what makes this command work efficiently.)

6. Show Addresses Assigned to Interfaces in a VRF
    ip [-br][-6] addr show master VRF-NAME

7. Show Routes for a VRF
    ip [-6] route show table ID

8. Route Lookup for a VRF
    ip [-6] route get oif VRF-NAME ADDRESS

    (This one needs a kernel patch to display the correct entry.)

David
