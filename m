From: Cong Wang <cwang@twopensource.com>
Subject: Re: VRFs and the scalability of namespaces
Date: Mon, 29 Sep 2014 11:05:36 -0700
Message-ID: <CAHA+R7MjgT6u7ptRqURJ5mZgdxdhrHcjD4aHL0CXayYWTCxJxQ@mail.gmail.com>
References: <5425EAA6.7040302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:59295 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754888AbaI2SFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 14:05:39 -0400
Received: by mail-lb0-f169.google.com with SMTP id u10so5012869lbd.14
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 11:05:38 -0700 (PDT)
In-Reply-To: <5425EAA6.7040302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 3:37 PM, David Ahern <dsahern@gmail.com> wrote:
>
> Network Namespaces for VRFs
> ---------------------------
> For the past 4 years or so the response to VRF questions is a drum beat of
> "use network namespaces". But namespaces are not a good match for VRFs.
>
> 1. Network namespaces are a complete separation of the networking stack from
> network devices up. VRFs are an L3 concept. Using namespaces forces an L3
> separation concept onto L2 apps -- lldp, cdp, etc.
>
> There are use cases when you want device level separation, use cases where
> you want only L3 and up separation, and cases where you want both (e.g.,
> divy up the netdevices in a system across some small number of namespaces
> and then provide VRF based features within a namespace).


With regarding to L3 isolation, not limited to VRF, it _does_ sound
like a cleaner
solution than the current L2 isolation, given the fact that:

1) Isolating L2 relies on /sys etc. in practice, which means we have to use
mount namespace as well. Ideally network isolation should be independent of
other namespaces.

2) Some resources still need to be shared, otherwise we have to restart
some services in each of network namespaces as you mentioned. The
~200kb memory overhead is not a problem I think, as now most servers have 8Gb+
memory, the real problem is some service, for example udevd, has some
dependencies, we would fall back to re-implement a whole init service
chain for each
netns, which is the expensive part.

Overall, rather than all or none isolation, we should give the user
some flexibility
to specify which network resources we want to isolation, which we don't. Again,
I am not saying VRF is the solution, I am looking for some more
flexible isolation
solution.

Thanks.
