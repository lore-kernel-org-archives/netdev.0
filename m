From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: RFC: Reproducible oops with lockdep on count_matching_names()
Date: Mon, 5 Nov 2007 15:26:40 +0100
Message-ID: <200711051526.41273.mb@bu3sch.de>
References: <20071101191716.GA3201@pogo> <200711051403.39479.mb@bu3sch.de> <84144f020711050556m6675ea90g1b6c8054a3940ec0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Peter Zijlstra" <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	"Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Michael Wu" <flamingice-R9e9/4HEdknk1uMJSBkQmQ@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"Ingo Molnar" <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Johannes Berg" <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Michael Chan" <mchan-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Christoph Lameter" <clameter-sJ/iWh9BUns@public.gmane.org>
To: "Pekka Enberg" <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <84144f020711050556m6675ea90g1b6c8054a3940ec0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 05 November 2007 14:56:22 Pekka Enberg wrote:
> Hi Michael,
> 
> On Monday 05 November 2007 13:23:50 Pekka Enberg wrote:
> > > Is CONFIG_DEBUG_SLAB enabled? Usually these kind of random corruptions
> > > are caused by someone passing a bad pointer to kfree() or
> > > kmem_cache_free().
> 
> On 11/5/07, Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:
> > Yeah.
> >
> > What I also saw was random "one-bit-errors" once and then on rmmod of modules.
> > I have absolutely no idea how they were caused, though (I read the freeing
> > codes of the stuff hundreds of times). I don't have any of the oops messages
> > anymore.
> > But I do _not_ see this behaviour with slub anymore.
> 
> It is possible that the corruption is still there but SLUB doesn't
> show it. Have you tried with slub_debug enabled?

Hm, I don't really remember. Though, I usually have all almost kernel-hacking
options enabled.
I'll check and enable some more.

> > BUG: unable to handle kernel paging request at virtual address f88a4a05
> > printing eip: f88a4a05 *pde = 02000067 *pte = 00000000
> >
> > EIP: 0060:[<f88a4a05>] EFLAGS: 00010086 CPU: 0
> > EIP is at 0xf88a4a05
> > EAX: c20b75c8 EBX: c2f86f38 ECX: f88a4a05 EDX: c2f86f38
> > ESI: c20b75c8 EDI: c2f89c00 EBP: c3897bfc ESP: c3897be0
> >  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> > Process modprobe (pid: 2908, ti=c3896000 task=c3935150 task.ti=c3896000)
> > Stack: c01b2afc c2f82d98 c3897bf4 c01ba8b6 c2f86f38 c20b75c8 c2f82c00 c3897c24
> >       c02186dd c2f86f38 c3897c24 c01b54c0 c20b75c8 00000001 c20b75c8 c2f86f38
> >       c20b75c8 c3897c30 c01b54ed 00000001 c3897c54 c01b556c 00000001 c3897cd4
> > Call Trace:
> >  [<c0104cec>] show_trace_log_lvl+0x1a/0x2f
> >  [<c0104d9e>] show_stack_log_lvl+0x9d/0xa5
> >  [<c0104e53>] show_registers+0xad/0x17c
> >  [<c0105017>] die+0xf5/0x1c6
> >  [<c0112715>] do_page_fault+0x450/0x537
> >  [<c02a835a>] error_code+0x6a/0x70
> >  [<c02186dd>] scsi_request_fn+0x5f/0x2ec
> >  [<c01b54ed>] __generic_unplug_device+0x20/0x23
> 
> We jump to a bogus address 0xf88a4a05 via a function pointer from
> scsi_request_fn(). Can you work out the exact file and line for
> scsi_request_fn+0x5f (look for "gdb vmlinux" in
> Documentation/BUG-HUNTING) please?

That'd be Luis' task then :)


-- 
Greetings Michael.
