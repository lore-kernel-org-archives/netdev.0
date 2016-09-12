From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH 00/26] constify local structures
Date: Mon, 12 Sep 2016 15:57:40 +0200
Message-ID: <CAMuHMdXuvrY987eTOmV+Ltaev=LrsDGuuE0+mmjJB7cAr+19ug@mail.gmail.com>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
 <20160911172105.GB5493@intel.com> <alpine.DEB.2.10.1609121051050.3049@hadrien>
 <20160912131625.GD957@intel.com> <877fah5j35.fsf@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com>,
        Julia Lawall <julia.lawall@lip6.fr>,
        Linux-Renesas <linux-renesas-soc@vger.kernel.org>,
        Joe Perches <joe@perches.com>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Linux PM list <linux-pm@vger.kernel.org>,
        platform-driver-x86@vger.kernel.org,
        Linux Media Mailing List <linux-media@vger.kernel.org>,
        linux-can@vger.kernel.org,
        Tatyana Nikolova <tatyana.e.nikolova@intel.com>,
        Shiraz Saleem <shiraz.saleem@intel.com>,
        Mustafa Ismail <mustafa.ismail@intel.com>,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        driverdevel <devel@driverdev.osuosl.org>,
To: Felipe Balbi <felipe.balbi@linux.intel.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <877fah5j35.fsf@linux.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 12, 2016 at 3:43 PM, Felipe Balbi
<felipe.balbi@linux.intel.com> wrote:
> Jarkko Sakkinen <jarkko.sakkinen@linux.intel.com> writes:
>> On Mon, Sep 12, 2016 at 10:54:07AM +0200, Julia Lawall wrote:
>>> On Sun, 11 Sep 2016, Jarkko Sakkinen wrote:
>>> > On Sun, Sep 11, 2016 at 03:05:42PM +0200, Julia Lawall wrote:
>>> > > Constify local structures.
>>> > >
>>> > > The semantic patch that makes this change is as follows:
>>> > > (http://coccinelle.lip6.fr/)
>>> >
>>> > Just my two cents but:
>>> >
>>> > 1. You *can* use a static analysis too to find bugs or other issues.
>>> > 2. However, you should manually do the commits and proper commit
>>> >    messages to subsystems based on your findings. And I generally think
>>> >    that if one contributes code one should also at least smoke test changes
>>> >    somehow.
>>> >
>>> > I don't know if I'm alone with my opinion. I just think that one should
>>> > also do the analysis part and not blindly create and submit patches.
>>>
>>> All of the patches are compile tested.  And the individual patches are
>>
>> Compile-testing is not testing. If you are not able to test a commit,
>> you should explain why.
>
> Dude, Julia has been doing semantic patching for years already and
> nobody has raised any concerns so far. There's already an expectation
> that Coccinelle *works* and Julia's sematic patches are sound.

+1

> Besides, adding 'const' is something that causes virtually no functional
> changes to the point that build-testing is really all you need. Any
> problems caused by adding 'const' to a definition will be seen by build
> errors or warnings.

Unfortunately in this particular case they could lead to failures that can only
be detected at runtime, when failing o write to a read-only piece of memory,
due to the casting away of the constness of the pointers later.
Fortunately this was detected during code review (doh...).

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
