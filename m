From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 3/3] net: Add GRO support for vxlan traffic
Date: Wed, 8 Jan 2014 11:45:34 +0200
Message-ID: <52CD1E3E.3090806@mellanox.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>	<1389108594-665-4-git-send-email-ogerlitz@mellanox.com>	<CA+mtBx-fUe_VbUUnjEVXeJO=87yypoDuMfoctO0Q3nMx+6UZFA@mail.gmail.com>	<CAJZOPZKHC1t6tGjZ9ZyTD912-5Bw_Vtin8N2MnqkOi4W2wPrzA@mail.gmail.com>	<1389124947.26646.54.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJZOPZ+_1z+Qq0U0XnEAMygXMXTivN7giZ5P-QH-L_dkz2_hFw@mail.gmail.com> <CA+mtBx_Zctape7mAA=d-bvrFJbzn8f6tW5jBnPUcL5Cfhfai-g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jerry Chu <hkchu@google.com>,
	"Eric Dumazet" <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog102.obsmtp.com ([207.126.144.113]:52520 "EHLO
	eu1sys200aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755152AbaAHJq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 04:46:59 -0500
In-Reply-To: <CA+mtBx_Zctape7mAA=d-bvrFJbzn8f6tW5jBnPUcL5Cfhfai-g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/01/2014 23:09, Tom Herbert wrote:
> On Tue, Jan 7, 2014 at 12:12 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> On Tue, Jan 7, 2014 at 10:02 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Tue, 2014-01-07 at 21:43 +0200, Or Gerlitz wrote:
>>>> On Tue, Jan 7, 2014 at 8:08 PM, Tom Herbert <therbert@google.com> wrote:
>>>>> Why ^ instead of != ?
>>>> The XOR approach is very popular in the GRO stack, e.g see the IPv4 chain
>>>> of inet_gro_receive() && tcp_gro_receive(), I guess this might relates
>>>> to more efficient assembly code for ^ vs. != and/or the fast/elegant
>>>> transitive nature of that operator
>>> This trick is only needed/used when many compares are folded into a
>>> single conditional :
>>>
>>> if (a->f1 != b->f1 || a->f2 != b->f2)
>>>
>>> ->
>>>
>>> if (((a->f1 ^ b->f1) | (a->f2 ^ b->f2)) != 0)
>>>
>>> Please do not use XOR for a single compare.
>> OK, but just out of curiosity -- what's the reasoning? clarity or
>> efficiency or both?
> Both. Compiling a simple program and comparing alternatives: gcc
> produced the identical code for the single conditional (^ vs !=)
> using the cmp instruction. Testing the two conditional case like Eric
> provided; the second method (using ^) resulted in 4 more instructions,
> but only one branch as opposed to two in the first method (!=). Method
> #1 has the advantage of short circuiting when the first condition is
> true, so organizing the conditionals to maximize the probability of
> short circuit could be beneficial.

OK, I will follow that.

Or.
