From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] tree-wide: replace config_enabled() with IS_ENABLED()
Date: Tue, 7 Jun 2016 15:29:30 -0700
Message-ID: <20160607152930.71273719bdaea322814213d0@linux-foundation.org>
References: <1465215656-20569-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Stas Sergeev <stsp@list.ru>,
        Matt Redfearn <matt.redfearn@imgtec.com>,
        Joshua Kinard <kumba@gentoo.org>, Jiri Slaby <jslaby@suse.com>,
        Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org,
        Borislav Petkov <bp@suse.de>, dri-devel@lists.freedesktop.org,
        Markos Chandras <markos.chandras@imgtec.com>,
        "Dmitry V. Levin" <ldv@altlinux.org>,
        yu-cheng yu <yu-cheng.yu@intel.com>,
        James Hogan <james.hogan@imgtec.com>,
        Brian Gerst <brgerst@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        Peter Zijlstra <peterz@infradead.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Will Drewry <wad@chromium.org>,
        Nikolay Martynov <mar.kolya@gmail.com>,
        Huacai Chen <chenhc@lemote.com>, x86@kernel.org,
        "H. Peter Anvin" <hpa@zytor.com>,
        Thom
To: Masahiro Yamada <yamada.masahiro@socionext.com>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1465215656-20569-1-git-send-email-yamada.masahiro@socionext.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

On Mon,  6 Jun 2016 21:20:56 +0900 Masahiro Yamada <yamada.masahiro@socionext.com> wrote:

> The use of config_enabled() against config options is ambiguous.
> In practical terms, config_enabled() is equivalent to IS_BUILTIN(),
> but the author might have used it for the meaning of IS_ENABLED().
> Using IS_ENABLED(), IS_BUILTIN(), IS_MODULE() etc. makes the
> intention clearer.
> 
> This commit replaces config_enabled() with IS_ENABLED() where
> possible.  This commit is only touching bool config options.
> 
> I noticed two cases where config_enabled() is used against a tristate
> option:
> 
>  - config_enabled(CONFIG_HWMON)
>   [ drivers/net/wireless/ath/ath10k/thermal.c ]
> 
>  - config_enabled(CONFIG_BACKLIGHT_CLASS_DEVICE)
>   [ drivers/gpu/drm/gma500/opregion.c ]
> 
> I did not touch them because they should be converted to IS_BUILTIN()
> in order to keep the logic, but I was not sure it was the authors'
> intention.

Well, we do want to be able to remove config_enabled() altogether if
we're going to do this.  So please later send along a patch which makes
a best-effort fix of the unclear usages and let's zap the thing.

If those fixes weren't quite correct then there will be a build error
(drivers/net/wireless/ath/ath10k/thermal.c) or no change in behaviour
(drivers/gpu/drm/gma500/opregion.c).
