From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: myri10ge conversion to non-contiguous skb
Date: Sun, 27 Aug 2006 23:36:38 -0700
Message-ID: <4807377b0608272336v1d64bc5bh320dee7f08667f79@mail.gmail.com>
References: <44EE2791.50101@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:57011 "EHLO
	ug-out-1314.google.com") by vger.kernel.org with ESMTP
	id S932396AbWH1Ggj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 02:36:39 -0400
Received: by ug-out-1314.google.com with SMTP id m3so1505658ugc
        for <netdev@vger.kernel.org>; Sun, 27 Aug 2006 23:36:38 -0700 (PDT)
To: "Brice Goglin" <brice@myri.com>
In-Reply-To: <44EE2791.50101@myri.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/24/06, Brice Goglin <brice@myri.com> wrote:
> During the submission of the myri10ge driver, some people raised the
> question of using pages (or any kind of non-contiguous skb) instead of
> our current 16kB contiguous skb. We are looking at this right now and it
> is not clear what solution is the best. From what we understand, Linux
> provides two mostly redundant mechanisms to handle discontinuous skb,
> the skb->frags and the skb->frag_list, s2io using the latter while e1000
> uses the former. Is one or the other recommended? What is the purpose of
> having them both in the net core?

you really only have one option, to use PAGE_SIZE pages and frags[]
w/nr_frags.  e1000 tried the frag_list option but that is used by ip
reassembly and badly conflicts with driver generated frag_list.
