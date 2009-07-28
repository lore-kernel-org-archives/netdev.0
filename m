From: Hannes Eder <heder@google.com>
Subject: Re: [RFC][PATCH 1/5] IPVS: prefix EnterFunction and LeaveFunction msg
	with "IPVS:"
Date: Tue, 28 Jul 2009 13:15:04 +0200
Message-ID: <b5ddba180907280415y4a9ef71i5cd90ca409b52965@mail.gmail.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
	 <20090727134616.12897.7639.stgit@jazzy.zrh.corp.google.com>
	 <alpine.LSU.2.00.0907272013070.20984@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <lvs-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0907272013070.20984@fbirervta.pbzchgretzou.qr>
Sender: lvs-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2009 at 20:14, Jan Engelhardt<jengelh@medozas.de> wrote=
:
>
> On Monday 2009-07-27 15:46, Hannes Eder wrote:
>>
>>Now all printk messages from IPVS are prefixed with "IPVS:".
>>
>>+#define EnterFunction(level) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>>+ =A0 =A0 =A0do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 \
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (level <=3D ip_vs_get_debug_level()) =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_DEBUG "IPVS:=
 Enter: %s, %s line %i\n", =A0 =A0 \
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__=
, __FILE__, __LINE__); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>>+ =A0 =A0 =A0} while (0)
>>+#define LeaveFunction(level) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>>+ =A0 =A0 =A0do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 \
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0if (level <=3D ip_vs_get_debug_level()) =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_DEBUG "IPVS:=
 Leave: %s, %s line %i\n", =A0 =A0 \
>>+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__=
, __FILE__, __LINE__); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>>+ =A0 =A0 =A0} while (0)
>
> I think you should rather make use of pr_fmt:
>
> <before any #includes>
> #define pr_fmt(x) "IPVS: " x
>
> And then use pr_<level>("Elvis has left the building") in code. This
> will add IPVS: automatically to all pr_* calls, alleviating the need
> to manually type it into all printks.

I like this idea.  I'll come up with an extra patch, it does not fit
into this series anyway.

> Of course, if you only want it for the two defines here, scrap
> my idea :)
>

Cheers,
-Hannes
