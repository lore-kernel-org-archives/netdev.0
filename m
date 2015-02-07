From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vxlan: Wrong type passed to %pIS
Date: Sat, 7 Feb 2015 15:31:42 -0800
Message-ID: <CAM_iQpVisStscGn4QDxb7f3aeGT8nc6Ho3PPSFHM3NB5s2Ue0A@mail.gmail.com>
References: <1423275451-3663-1-git-send-email-linux@rasmusvillemoes.dk>
	<CAM_iQpWGR6zLrGLGsMPM1Y-z45Nd4XO3X_H1KDTedsz2=5mXng@mail.gmail.com>
	<87wq3tnbn0.fsf@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87wq3tnbn0.fsf@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 7, 2015 at 4:34 AM, Rasmus Villemoes
<linux@rasmusvillemoes.dk> wrote:
> On Sat, Feb 07 2015, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>
>> On Fri, Feb 6, 2015 at 6:17 PM, Rasmus Villemoes
>> <linux@rasmusvillemoes.dk> wrote:
>>> src_ip is a pointer to a union vxlan_addr, one member of which is a
>>> struct sockaddr. Passing a pointer to src_ip is wrong; one should pass
>>> the value of src_ip itself. Since %pIS formally expects something of
>>> type struct sockaddr*, let's pass a pointer to the appropriate union
>>> member, though this of course doesn't change the generated code.
>>>
>>
>>
>> It is a union, this doesn't harm.
>>
>
> Just to be clear: This fixes a real bug. The minimal fix had been
>
> -                     src_mac, &rdst->remote_ip, &src_ip);
> +                     src_mac, &rdst->remote_ip, src_ip);
>
> but I through in the cosmetic improvements while the line needed
> changing anyway.
>

Ah, I misread the patch.

Acked-by: Cong Wang <xiyou.wangcong@gmail.com>

Thanks!
