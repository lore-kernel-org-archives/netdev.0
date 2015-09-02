From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2] net: Add table id from route lookup to route
 response
Date: Wed, 2 Sep 2015 14:47:08 -0600
Message-ID: <55E7604C.8070603@cumulusnetworks.com>
References: <20150902190836.GD20527@pox.localdomain>
 <1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
 <55E75EE4.2050602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:33846 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755345AbbIBUrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:47:11 -0400
Received: by igcpb10 with SMTP id pb10so35246977igc.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:47:10 -0700 (PDT)
In-Reply-To: <55E75EE4.2050602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/2/15 2:41 PM, Alexander Duyck wrote:
>
> Why not implement this this same for IPv4 and IPv6?  It looks like it is
> only included if it is non-zer and not MAIN in the above case, and then
> below as long as a table ID is non-zero you are setting the value.  Why
> not just include the value in all cases where it is defined just like
> for IPv6?
>

I like Thomas' suggestion to add an rtm_flag better. We only need to fix 
IPv4 which hardcodes the tableid. Adding a flag, e.g.,

+#define RTM_F_LOOKUP_TABLE     0x1000  /* set rtm_table to FIB lookup 
result */

signifies the caller wants the real table. When set rt_fill_info sets 
rtm_table to the actual table id. This allows updated tools to work 
properly for both ipv4 and ipv6 and without breaking existing userspace.
