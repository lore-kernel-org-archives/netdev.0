From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 12/14] netlink: add documentation for memory mapped I/O
Date: Wed, 17 Apr 2013 20:08:06 +0200
Message-ID: <1e17db69-0d5c-40dc-81ac-2904aab008c3@email.android.com>
References: <1366217229-22705-1-git-send-email-kaber@trash.net> <1366217229-22705-13-git-send-email-kaber@trash.net> <516EE10D.2080608@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61561 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964924Ab3DQSIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 14:08:18 -0400
In-Reply-To: <516EE10D.2080608@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Daniel Borkmann <dborkman@redhat.com> schrieb:

>On 04/17/2013 06:47 PM, Patrick McHardy wrote:
>> Signed-off-by: Patrick McHardy <kaber@trash.net>
>> ---
>[...]
>> +Ring frames
>> +------------
>> +
>> +Each frames contain a frame header, consisting of a synchronization
>word and some
>> +meta-data, and the message itself.
>> +
>> +Frame:	[ header message ]
>> +
>> +The frame header is defined as follows:
>> +
>> +struct nl_mmap_hdr {
>> +	unsigned int	nm_status;
>> +	unsigned int	nm_len;
>> +	__u32		nm_group;
>> +	/* credentials */
>> +	__u32		nm_pid;
>> +	__u32		nm_uid;
>> +	__u32		nm_gid;
>> +};
>
>Hm, just wondering, maybe it could be a safer path to make 'nm_status'
>and 'nm_len' also of fixed width as the rest of nl_mmap_hdr, and as in
>PF_PACKET's tpacket2_hdr and tpacket3_hdr ?
>--
>To unsubscribe from this list: send the line "unsubscribe
>netfilter-devel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

The size of int is not going to change, but I agree that it is cleaner. I'll send a patch to change this once/if this is merged.

Thanks.
