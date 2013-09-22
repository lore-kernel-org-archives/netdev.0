From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 1/2] remove all uses of printf's %n
Date: Sun, 22 Sep 2013 10:16:36 +0200
Message-ID: <CAMuHMdVdgmio-VGhLRZBZBP8GL1bHDtu4z23z5jqSJKoOj4iXg@mail.gmail.com>
References: <201309191756.BCF65661.MQFOLSJOFHFtOV@I-love.SAKURA.ne.jp>
	<CAGXu5jK_D1BJOQr=1A-UFrpM5Ad+Qu894HT_XjkZh4EmsbCkTQ@mail.gmail.com>
	<201309201309.GFB52620.OQOtSFLMJVHOFF@I-love.SAKURA.ne.jp>
	<523C0268.20404@suse.cz>
	<CAGXu5jLENb+x6b9XOY7-pWMT7GsFgnLr0=A8VNFLkqMi0BX4=w@mail.gmail.com>
	<201309210928.JCF90671.OtOFLFQSOJVFMH@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>, Jiri Slaby <jslaby@suse.cz>,
	Al Viro <viro@zeniv.linux.org.uk>, xemul@openvz.org,
	remi.denis-courmont@nokia.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org, George Spelvin <linux@horizon.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Jan Beulich <JBeulich@suse.com>, Joe Perches <joe@perches.com>,
	Motohiro KOSAKI <kosaki.motohiro@gmail.com>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:42593 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076Ab3IVIQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 04:16:36 -0400
In-Reply-To: <201309210928.JCF90671.OtOFLFQSOJVFMH@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 2:28 AM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Kees Cook wrote:
>> >> -                     seq_printf(seq, "%*s\n", 127 - len, "");
>> >> +                     seq_pad(seq, '\n');
>> >
>> > Hmm, seq_pad is unintuitive. I would say it pads the string by '\n'. Of
>> > course it does not, but...
>>
>> I don't think this is a very serious problem. Currently, the padding
>> character is always ' ' for all existing callers, so it only makes
>> sense to make the trailing character an argument.
>
> If you want, we can rename seq_pad() to seq_pad_and_putc(). Also we can pass
> both the padding character (e.g. ' ') and the trailing character (e.g. '\n')
> like seq_pad_and_putc((' ' << 8) | '\n'), though I wonder someone wants to
> use '\0', '\t', '\n' etc. as the padding character...

Not those special characters. '-' could be useful for tables (doh,
text-mode graphics
log output).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
