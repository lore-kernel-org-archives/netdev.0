From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: patches for PROC_FS=n (2.6.0-test7)
Date: Mon, 13 Oct 2003 23:12:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031013231231.791317ff.rddunlap@osdl.org>
References: <Pine.GSO.4.58.0310101519330.9806@inky>
	<20031012201316.7ecf73c8.rddunlap@osdl.org>
	<Pine.GSO.4.58.0310132128450.8530@blinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Elmer.Joandi@ut.ee, elmer@ylenurme.ee, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Noah J. Misch" <noah@caltech.edu>
In-Reply-To: <Pine.GSO.4.58.0310132128450.8530@blinky>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Oct 2003 22:52:56 -0700 (PDT) "Noah J. Misch" <noah@caltech.edu> wrote:

| Randy,
| 
| I poked around the driver a bit and uncovered a few points that suggest to me a
| different approach to the problem.
| 
| The file arlan-proc.c contains a number of functions supporting the driver's
| sysctl interface.  Nothing in that file appears procfs-specific.

Right.

| I would change the Makefile to compile arlan-proc.c depending on CONFIG_SYSCTL
| and remove the #ifdef CONFIG_PROC_FS guarding much of that file.  I would then
| make arlan.h define macro or static inline stubs for init_arlan_proc and
| cleanup_arlan_proc much like the current arlan.h does.

That's about what I was planning to do next if I didn't hear anything
else from Elmer.

| For the matter, perhaps one could add an extra config option, ARLAN_SYSCTL, that
| depends on ARLAN and SYSCTL, and conditional-compile arlan-proc.c on that
| instead of CONFIG_SYSCTL itself.  That way, users could leave it out to save
| space without zapping all sysctls.  I would go for this approach myself.

I wouldn't prefer this, but if you make the patch, do whatever you want.
I think that CONFIG_SYSCTL should be enough to determine/decide/control it.

| The configuration help text for the arlan driver claims that it builds a module
| for the driver and another for its sysctl interface.  It doesn't do that at the
| moment, but that is another option (though not one I like as much).

I missed this config help text.  Glad you caught it.
But I wouldn't make that a separate module.

| What do you think?

Go ahead, your choice, but my preferences are above.


| On Sun, 12 Oct 2003, Randy.Dunlap wrote:
| 
| > On Fri, 10 Oct 2003 16:06:29 -0700 (PDT) "Noah J. Misch" <noah@caltech.edu> wrote:
| >
| > | > There are several other drivers/protocols that don't build
| > | > with PROC_FS=n, like arlan, siimage, ipx, llc, and bluetooth.
| >
| >
| > Here's a patch for the wireless/arlan driver for PROC_FS=n.
| > Currently it defines both a function and a macro for
| > init_arlan_proc() if PROC_FS=n.  This causes a bunch of
| > compile-time errors.
| >
| > It looks to me like it should always call the init_arlan_proc()
| > (and cleanup_arlan_proc()) functions since it inits some sysctl tables.
| > Or am I misunderstanding it?

Thanks.  And I hope that your mailbox is functional now.

--
~Randy
