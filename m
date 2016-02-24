From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH 0/5] net_sched: Add support for IFE action
Date: Wed, 24 Feb 2016 18:58:27 +0100
Message-ID: <56CDEF43.1010402@iogearbox.net>
References: <1456147304-13355-1-git-send-email-jhs@emojatatu.com> <56CB3B90.8030206@iogearbox.net> <56CC4BEA.70108@mojatatu.com> <56CC5CB6.1030807@iogearbox.net> <56CC6C75.1000903@mojatatu.com> <56CC7C20.3090302@iogearbox.net> <56CDA6E8.7010604@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com,
	alexei.starovoitov@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35122 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbcBXR6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 12:58:41 -0500
In-Reply-To: <56CDA6E8.7010604@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/24/2016 01:49 PM, Jamal Hadi Salim wrote:
> On 16-02-23 10:34 AM, Daniel Borkmann wrote:
[...]
>> My concern is we add 20 new modules like this that only do trivial things,
>> where instead they could have been consolidated and reduce maintenance. Or
>> is this hard module requirement related to the IFE_META_* module parameter?
>
> Yes, a bit of that ++.
> I am between two worlds: There are people who do user space packet
> processing that claim they do so because they can quickly prototype
> without compiling the kernel. My goal is to make it easy for people
> adding new metadata without having to deal with kernel recompile.

Seems like a case for cls_bpf? ;)

> I do expect for there to be many variations of what that metadata
> will be. For that reason I have them as standalone modules and they
> serve the purpose to illustrate how someone would write such a module.
> The IFE_META_XXX is part of saying i dont need to have people
> changing the header file either. But i want them to use static
> META_IDS. So the IFE module parameter is supposed to allow them to
> change the upper bound of modules when insmoding ife_act so that
> proper validation can happen. I cant make it as large as 32-bit
> or not check if it is correct. If i take it out - then i would have to
> do that or introduce some complex mechanism for registration.

Ok, sure, given the assumption that this is only to be used in your own
fully _controlled_ environment anyway. But in that case, you don't even
need to define any fixed IDs. Currently it seems like you could have
different kernel versions with different IFE_META_MAX from the kernel
headers and external modules define part of the ID space differently?

Thanks,
Daniel
