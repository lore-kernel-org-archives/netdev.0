From: Brice Goglin <brice@myri.com>
Subject: Re: myri10ge conversion to non-contiguous skb
Date: Tue, 29 Aug 2006 00:41:39 -0400
Message-ID: <44F3C583.2030900@myri.com>
References: <44EE2791.50101@myri.com> <4807377b0608272336v1d64bc5bh320dee7f08667f79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:51910 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1750846AbWH2Eln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 00:41:43 -0400
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
In-Reply-To: <4807377b0608272336v1d64bc5bh320dee7f08667f79@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesse Brandeburg wrote:
> On 8/24/06, Brice Goglin <brice@myri.com> wrote:
>> During the submission of the myri10ge driver, some people raised the
>> question of using pages (or any kind of non-contiguous skb) instead of
>> our current 16kB contiguous skb. We are looking at this right now and it
>> is not clear what solution is the best. From what we understand, Linux
>> provides two mostly redundant mechanisms to handle discontinuous skb,
>> the skb->frags and the skb->frag_list, s2io using the latter while e1000
>> uses the former. Is one or the other recommended? What is the purpose of
>> having them both in the net core?
>
> you really only have one option, to use PAGE_SIZE pages and frags[]
> w/nr_frags.  e1000 tried the frag_list option but that is used by ip
> reassembly and badly conflicts with driver generated frag_list.

Ok, thanks for the clarification, we'll use frags then.

Is s2io going to be converted from frag_list to frags then?

Brice


