From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH V3 2/2] debugfs: don't assume sizeof(bool) to be 4 bytes
Date: Tue, 15 Sep 2015 10:38:32 -0700
Message-ID: <CA+55aFxVQ9jD=jUqPZt76EMe_Tb-_SA8v=rOHeR9Ljdsc6=xGQ@mail.gmail.com>
References: <9b705747a138c96c26faee5218f7b47403195b28.1442305897.git.viresh.kumar@linaro.org>
	<27d37898b4be6b9b9f31b90135f8206ca079a868.1442305897.git.viresh.kumar@linaro.org>
	<1442313464.1914.21.camel@sipsolutions.net>
	<20150915110447.GI6350@linux>
	<20150915094509.46cca84d@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "open list:NETWORKING DRIVERS \(WIRELESS\)"
	<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"moderated list:SOUND - SOC LAYER / DYNAMIC AUDIO POWER MANAGEM..."
	<alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org>, "Altman, Avri" <avri.altman-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"open list:DOCUMENTATION" <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Sebastian Andrzej Siewior <bigeasy-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, Jaroslav Kysela <perex-/Fr2/VpizcU@public.gmane.org>,
	"open list:MEMORY MANAGEMENT" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
	Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>, "Grumbach,
	Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, "Coelho,
	Luciano" <luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, Wang Long <long.wanglong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Richard Fitzgerald <rf-yzvPICuk2AATkU/dhu1WVueM+bqZidxxQQ4Iyu8u01E@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, open list <linux-kerne
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150915094509.46cca84d-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/iommu/>
List-Post: <mailto:iommu-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/iommu>,
	<mailto:iommu-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: iommu-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 15, 2015 at 6:45 AM, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
>
> Linus, This patch changes a lot of u32s into bools in structures.
> What's your take on that?

So in general, I'd tend to prefer "bool" to be used primarily as a
return value for functions, but I have to say, in the case of
something that is explicitly called "debugfs_create_bool()" it kind of
makes sense to actually take a bool pointer.

In structures, it depends a bit on usage. If the intent is to pack
things better, I tend to prefer using "char" etc that is explicitly a
byte. Or just use explicit bits in an "unsigned int flags" or
something. Because while "bool" is _typically_ one byte, but it's very
very explicitly documented to not be guaranteed that way, and there
are legacy models where "bool" ends up being "int".

But in this case, the use of "bool" is not about packing or anything
like that, it is more about the logical data type for
"debugfs_create_bool()", and so I don't mind "bool" in this context
even in structures.

But exactly because of the whole ambiguoity about "bool", what I do
*not* want to see in any way is "bool" in structures that are exported
to user space. That's when we want primarily those explicitly sized
types like "u32" etc. We should generally try to avoid even things
like "int" in those kinds of structures, and bool is even _less_ well
defined than "int" is.

But that user interface issue doesn't seem to be the case here, an I
can't say that I mind the patch. It looks fairly sane.

                    Linus
