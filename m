From: Tom Herbert <tom@herbertland.com>
Subject: Re: [RFC PATCH net] vxlan: fix incorrect RCO bit in VXLAN header
Date: Fri, 4 Dec 2015 08:43:59 -0800
Message-ID: <CALx6S35_CbKfNpGJM6xsSgdkd25iekMCS3jwyG7_B5bCfeJhQw@mail.gmail.com>
References: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <therbert@google.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:35064 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754034AbbLDQoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 11:44:00 -0500
Received: by ioc74 with SMTP id 74so121409052ioc.2
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 08:43:59 -0800 (PST)
In-Reply-To: <67179e9385c71f7c377a7df345d445704f49dbbc.1449233631.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 4:54 AM, Jiri Benc <jbenc@redhat.com> wrote:
> Commit 3511494ce2f3d ("vxlan: Group Policy extension") changed definition of
> VXLAN_HF_RCO from 0x00200000 to BIT(24). This is obviously incorrect. It's
> also in violation with the RFC draft.
>
> Fixes: 3511494ce2f3d ("vxlan: Group Policy extension")
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Tom Herbert <therbert@google.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> This code is, unfortunately, in the tree since 4.0. Not sure whether we can
> change it now. On the other hand, we're in violation with the RFC draft and
> collide with VXLAN-GPE flags assignment which defines this bit as OAM flag.
>
> Opinions welcome, especially by Tom and Thomas.

Thanks Jiri!

What a mess VXLAN has become. There are no guidelines or order in
defining these reserved bits! If anyone is looking to do some work in
encapsulation please consider bringing up VXLAN-GPE/NSH in the stack,
hopefully that world will be better....

Acked-by: Tom Herbert <tom@herbertland.com>

> ---
>  include/net/vxlan.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/net/vxlan.h b/include/net/vxlan.h
> index c1c899c3a51b..e289ada6adf6 100644
> --- a/include/net/vxlan.h
> +++ b/include/net/vxlan.h
> @@ -79,7 +79,7 @@ struct vxlanhdr {
>  };
>
>  /* VXLAN header flags. */
> -#define VXLAN_HF_RCO BIT(24)
> +#define VXLAN_HF_RCO BIT(21)
>  #define VXLAN_HF_VNI BIT(27)
>  #define VXLAN_HF_GBP BIT(31)
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
