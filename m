From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: Sat, 21 Sep 2013 09:28:14 +0900
Message-ID: <201309210928.JCF90671.OtOFLFQSOJVFMH@I-love.SAKURA.ne.jp>
References: <201309191756.BCF65661.MQFOLSJOFHFtOV@I-love.SAKURA.ne.jp>
	<CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com>
	<201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
	<523C0268.20404@suse.cz>
	<CAGXu5jLENb+x6b9XOY7-pWMT7GsFgnLr0=A8VNFLkqMi0BX4=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: viro@zeniv.linux.org.uk, xemul@openvz.org,
	remi.denis-courmont@nokia.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux@horizon.com, akpm@linux-foundation.org,
	dan.carpenter@oracle.com, geert@linux-m68k.org, JBeulich@suse.com,
	joe@perches.com, kosaki.motohiro@gmail.com
To: keescook@chromium.org, jslaby@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGXu5jLENb+x6b9XOY7-pWMT7GsFgnLr0=A8VNFLkqMi0BX4=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook wrote:
> >> -                     seq_printf(seq, "%*s\n", 127 - len, "");
> >> +                     seq_pad(seq, '\n');
> >
> > Hmm, seq_pad is unintuitive. I would say it pads the string by '\n'. Of
> > course it does not, but...
> 
> I don't think this is a very serious problem. Currently, the padding
> character is always ' ' for all existing callers, so it only makes
> sense to make the trailing character an argument.

If you want, we can rename seq_pad() to seq_pad_and_putc(). Also we can pass
both the padding character (e.g. ' ') and the trailing character (e.g. '\n')
like seq_pad_and_putc((' ' << 8) | '\n'), though I wonder someone wants to
use '\0', '\t', '\n' etc. as the padding character...
