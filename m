From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 10/13] timer: Remove expires and data arguments from DEFINE_TIMER
Date: Thu, 5 Oct 2017 10:59:12 +0200
Message-ID: <CAK8P3a2uio4L3BMedHGg0wVy2asJ_CD8xqxevSnqdNDKOy6Vqw@mail.gmail.com>
References: <1507159627-127660-1-git-send-email-keescook@chromium.org> <1507159627-127660-11-git-send-email-keescook@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Thomas Gleixner <tglx@linutronix.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Chris Metcalf <cmetcalf@mellanox.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Guenter Roeck <linux@roeck-us.net>,
        Harish Patil <harish.patil@cavium.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        John Stultz <john.stultz@linaro.org>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>,
        Kalle Valo <kvalo@qca.qualcomm.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Len Brown <len.brown@intel.com>,
        Manish Chopra <manish.chopra@cavium.com>,
        Mark Gross <mark.gross@intel.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        M
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <1507159627-127660-11-git-send-email-keescook@chromium.org>
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

On Thu, Oct 5, 2017 at 1:27 AM, Kees Cook <keescook@chromium.org> wrote:
> Drop the arguments from the macro and adjust all callers with the
> following script:
>
>   perl -pi -e 's/DEFINE_TIMER\((.*), 0, 0\);/DEFINE_TIMER($1);/g;' \
>     $(git grep DEFINE_TIMER | cut -d: -f1 | sort -u | grep -v timer.h)
>
> Signed-off-by: Kees Cook <keescook@chromium.org>
> Acked-by: Geert Uytterhoeven <geert@linux-m68k.org> # for m68k parts

I was slightly worried about this large-scale rework, since it might conflict
with new users of DEFINE_TIMER(), causing bisection problems.

However, a little research showed that we have only added two users
in the past five years, so this is not a real concern.

for arch/arm, drivers/char and overall:

Acked-by: Arnd Bergmann <arnd@arndb.de>
