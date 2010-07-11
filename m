From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Sun, 11 Jul 2010 08:19:21 +0300
Message-ID: <4C395459.6080407@redhat.com>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>	 <AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>	 <1278626921.2435.73.camel@edumazet-laptop>	 <AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>	 <1278695580.2696.55.camel@edumazet-laptop>	 <AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com> <1278742649.2538.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Felipe W Damasio <felipewd@gmail.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44941 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750873Ab0GKFTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jul 2010 01:19:31 -0400
In-Reply-To: <1278742649.2538.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/10/2010 09:17 AM, Eric Dumazet wrote:
>
> Strange thing with your crash report is CR2 value, with unexpected value
> of 000000000b388000 while RAX value is dce8dce85d415d41
>
> Faulting instruction is :
>
> 48 83 b8 b0 00 00 00 00   cmpq   $0x0,0xb0(%rax)
>
> So I would have expected CR2 being RAX+0xb0, but its not.
>    

Nothing strange about it.  You only get page faults and valid cr2 for 
canonical addresses (17 high order bits all equal).  In this case 
rax+0xb0 is not a canonical address, so you got a general protection 
fault instead, with cr2 unchanged.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

