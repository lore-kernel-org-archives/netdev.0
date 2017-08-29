From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Tue, 29 Aug 2017 09:49:12 -0700 (PDT)
Message-ID: <20170829.094912.1121803194631886017.davem@davemloft.net>
References: <20170829112805.GB14571@kroah.com>
 <CAMuHMdVb-oygJkkHwBOfSmNECAfF72QruJSmVTpqdUW+RNJbrg@mail.gmail.com>
 <20170829144850.GC22532@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, samuel@sortiz.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, sbrivio@redhat.com, geert@linux-m68k.org
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170829144850.GC22532@kroah.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Date: Tue, 29 Aug 2017 16:48:50 +0200

> On Tue, Aug 29, 2017 at 02:11:39PM +0200, Geert Uytterhoeven wrote:
>> Hi Greg,
>> 
>> On Tue, Aug 29, 2017 at 1:28 PM, Greg Kroah-Hartman
>> <gregkh@linuxfoundation.org> wrote:
>> > On Tue, Aug 29, 2017 at 01:11:31PM +0200, Stefano Brivio wrote:
>> >> On Tue, 29 Aug 2017 12:59:00 +0200
>> >> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
>> >> > On Sun, Aug 27, 2017 at 5:03 PM, Greg Kroah-Hartman
>> >> > <gregkh@linuxfoundation.org> wrote:
>> >> > > The IRDA code has long been obsolete and broken.  So, to keep people
>> >> > > from trying to use it, and to prevent people from having to maintain it,
>> >> > > let's move it to drivers/staging/ so that we can delete it entirely from
>> >> > > the kernel in a few releases.
>> >> >
>> >> > (diving into an early boot crash)
>> >> >
>> >> > Have you tried running this? ;-)
>> >> >
>> >> > irda_init() and net_dev_init() are both subsys_initcall()s.
>> >> > But the former now runs before the latter, leading to:
>> >> >
>> >> > Unable to handle kernel NULL pointer dereference at virtual address 00000004
>> >>
>> >> Should be fixed by https://patchwork.ozlabs.org/patch/807006/
>> >> ("[net-next] staging: irda: force to be a kernel module") I guess...
>> >
>> > Yup, that's the fix for this issue.
>> >
>> > Geert, does that fix the problem for you?
>> 
>> Thanks, that patch fixes the crash, obviously.
>> 
>> It does mean you can no longer have IrDA in a non-modular kernel.
> 
> Given that irda doesn't really work, I doubt anyone is going to care
> about it :)

The initialization with everything built-in worked fine before your
changes.
