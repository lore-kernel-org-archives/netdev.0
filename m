From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [tcpdump-workers] Current wireless-testing breaks libpcap:
 mr_alen should be set
Date: Mon, 8 Mar 2010 09:11:35 +0100
Message-ID: <20100308081134.GA2816@psychotron.redhat.com>
References: <1267578048.14049.11.camel@mj>
 <7D621661-59E7-46C4-9E86-1D9654A626E7@alum.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tcpdump-workers@lists.tcpdump.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Guy Harris <guy@alum.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751681Ab0CHILp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 03:11:45 -0500
Content-Disposition: inline
In-Reply-To: <7D621661-59E7-46C4-9E86-1D9654A626E7@alum.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, Mar 06, 2010 at 10:23:12PM CET, guy@alum.mit.edu wrote:
>
>On Mar 2, 2010, at 5:00 PM, Pavel Roskin wrote:
>
>> This patch to libpcap helps:
>> 
>> --- a/pcap-linux.c
>> +++ b/pcap-linux.c
>> @@ -1563,6 +1563,7 @@ live_open_new(pcap_t *handle, const char
>> 			memset(&mr, 0, sizeof(mr));
>> 			mr.mr_ifindex = handle->md.ifindex;
>> 			mr.mr_type    = PACKET_MR_PROMISC;
>> +			mr.mr_alen    = 6;
>
>If there are any network types that support promiscuous mode and have link-layer addresses that aren't 6 octets long, that would still fail.
>
>It sounds as if the fix is not to care about the address length if the address isn't used, so you don't need to get the length right for PACKET_MR_PROMISC or PACKET_MR_ALLMULTI, so libpcap, and other clients setting promiscuous or "show me all multicast packets" mode, don't need to change.  Is that the case?

This should be fixed in kernel (net-2.6
1162563f82b434e3099c9e6c1bbdba846d792f0d)

Jirka
