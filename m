From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] qed: Add and use specific logging functions to reduce
 object size
Date: Tue, 26 Jul 2016 18:24:02 -0700
Message-ID: <1469582642.4159.4.camel@perches.com>
References: <a0e0111217e9df2ae8dfd681b2810230e00f634e.1469568146.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	everest-linux-l2@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a0e0111217e9df2ae8dfd681b2810230e00f634e.1469568146.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-07-26 at 14:25 -0700, Joe Perches wrote:
> Current DP_ macros generate a lot of code.
> Using functions with vsprintf extension %pV helps reduce that size.

Yuval, I used the same KERN_<LEVEL> output types, but it
is unusual that=A0DP_INFO outputs at KERN_NOTICE.

Was that a copy/paste defect or should it be emitted at
KERN_INFO and DP_VERBOSE be emitted at KERN_DEBUG?

> define DP_INFO(cdev, fmt, ...)					=A0=A0=A0=A0=A0=A0\
> -	do {							=A0=A0=A0=A0=A0=A0\
> -		if (unlikely((cdev)->dp_level <=3D QED_LEVEL_INFO)) {=A0=A0=A0\
> -			pr_notice("[%s:%d(%s)]" fmt,		=A0=A0=A0=A0=A0=A0\
> -				=A0=A0__func__, __LINE__,		=A0=A0=A0=A0=A0=A0\
> -				=A0=A0DP_NAME(cdev) ? DP_NAME(cdev) : "", \
> -				=A0=A0## __VA_ARGS__);		=A0=A0=A0=A0=A0=A0\
> -		}						=A0=A0=A0=A0=A0=A0\
> -	} while (0)
[]
> -#define DP_VERBOSE(cdev, module, fmt, ...)				\
> -	do {								\
> -		if (unlikely(((cdev)->dp_level <=3D QED_LEVEL_VERBOSE) &&	\
> -			=A0=A0=A0=A0=A0((cdev)->dp_module & module))) {		\
> -			pr_notice("[%s:%d(%s)]" fmt,			\
> -				=A0=A0__func__, __LINE__,			\
> -				=A0=A0DP_NAME(cdev) ? DP_NAME(cdev) : "",	\
> -				=A0=A0## __VA_ARGS__);			\
> -		}							\
> -	} while (0)
