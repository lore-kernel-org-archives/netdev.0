From: Cong Wang <cwang@twopensource.com>
Subject: Re: new link failing on duplicate names in different namespaces
Date: Wed, 25 Feb 2015 21:29:34 -0800
Message-ID: <CAHA+R7NA6UpC2cy7T14YAxW1gzVi=97yO23pWkkvj1DbV6sTdA@mail.gmail.com>
References: <CAOYZPENnpPP-N-ST3xYE7vcCFhbNd-FMKj9OvBebYSMu42OdaQ@mail.gmail.com>
	<54EDF7BB.2060809@6wind.com>
	<8761apubru.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Eugene Yakubovich <eugene.yakubovich@coreos.com>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:44248 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750762AbbBZF3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 00:29:35 -0500
Received: by iecar1 with SMTP id ar1so11223186iec.11
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 21:29:34 -0800 (PST)
In-Reply-To: <8761apubru.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 25, 2015 at 9:44 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
>
> The code that creates a network devices fundamentally needs to know
> about both namespaces network devices like the macvlan driver need
> to find their lower devices in the original network namespace.
>
> I think we could possibly remove the restriction for the names of newly
> created network devices being unique in both network namespaces but I
> don't think the code changes will be trivial.
>

We should add a flag to network devices, so that some devices which
don't have an underlying device, like veth, are allowed to be create right
in the given netns. Or, of course, just modify rtnl_newlink() if we have
some other clue (tb[IFLA_LINK] == NULL?).

I am working on a patch.
