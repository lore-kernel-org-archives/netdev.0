From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with
 IFLA_F_TEMPORARY flag
Date: Mon, 28 Oct 2013 09:56:18 -0400
Message-ID: <CAGCdqXHpQfkXHFjX8K-ptv=CxrpS2htJgWKzJTn=n+CDV6GpqA@mail.gmail.com>
References: <1382622355-6500-1-git-send-email-jiri@resnulli.us>
	<CAGCdqXHUW=RJf67qPXVRhPY__GAs02+G9mJV7agN5pDdfELXXA@mail.gmail.com>
	<20131027132941.GA1443@minipsycho.orion>
	<20131027164835.GB4714@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Jiri Pirko <jiri@resnulli.us>,
	Vladislav Yasevich <vyasevich@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>,
	thaller@redhat.com, Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:64942 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756004Ab3J1N4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 09:56:20 -0400
Received: by mail-wi0-f174.google.com with SMTP id cb5so3889967wib.1
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 06:56:19 -0700 (PDT)
In-Reply-To: <20131027164835.GB4714@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 27, 2013 at 12:48 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hi Jiri!
>
> On Sun, Oct 27, 2013 at 02:29:41PM +0100, Jiri Pirko wrote:
>> The idea is to provide possibility to do address configuration not in
>> kernel but rather in userspace (as it is done for example in NetworkManager)
>>
>> Maybe I'm missing something, but why is it problem to have the
>> possibility to set lifetime even for temporary prefix?
>
> There is no problem setting the lifetime for a temporary prefix (in
> contrary, it needs one) but the code paths designed for IFA_F_TEMPORARY
> may not fiddle with it. This needs to be checked.
>
> In this constellation addrconf_verify does not refresh the privacy
> address when its preferred lifetime is expired, if you create the
> address by only passing IFA_F_TEMPORARY to rtm_newaddr (as Vlad pointed
> out). E.g. NetworkManager has to take care about that, then.
>
> A temporary address is also bound to a non-privacy public address so
> it's lifetime is determined by its lifetime (e.g. if you switch the
> network and don't receive on-link information for that prefix any
> more). NetworkManager would have to take care about that, too. It is
> just a question of what NetworkManager wants to handle itself or lets
> the kernel handle for it.
>


Exactly.  If we want to re-use the as much of the kernel implementation as
possible, it might be nice to also add a regen notification in case there
is no public address.  This way, Network Manger (or another application)
can do the re-generation if need be for these user configured temporary
addresses.

-vlad


> Greetings,
>
>   Hannes
>
