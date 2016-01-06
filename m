From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH v2 net-next] net: Implement fast csum_partial for x86_64
Date: Tue, 05 Jan 2016 17:10:10 -0800
Message-ID: <568C6972.8020908@zytor.com>
References: <1452019261-449449-1-git-send-email-tom@herbertland.com> <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, kernel-team@fb.com,
	tglx@linutronix.de, mingo@redhat.com, x86@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:43393 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751873AbcAFBKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2016 20:10:35 -0500
In-Reply-To: <1452032313.8255.135.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/05/2016 02:18 PM, Eric Dumazet wrote:
> On Tue, 2016-01-05 at 10:41 -0800, Tom Herbert wrote:
>> Implement assembly routine for csum_partial for 64 bit x86. This
>> primarily speeds up checksum calculation for smaller lengths such as
>> those that are present when doing skb_postpull_rcsum when getting
>> CHECKSUM_COMPLETE from device or after CHECKSUM_UNNECESSARY
>> conversion.
> 
> Very nice !
> 
> 
> You might add a comment telling the '4' comes from length of 'adcq
> 6*8(%rdi),%rax' instruction, and that the 'nop' is to compensate that
> 'adcq    0*8(%rdi),%rax' is using 3 bytes instead.
> 
> We also could use .byte 0x48, 0x13, 0x47, 0x00 to force a 4 bytes
> instruction and remove the nop.
> 

Apparently "adcq.d8" will do The Right Thing for this.

	-hpa
