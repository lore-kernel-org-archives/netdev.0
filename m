From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: created new q_disc, inserted module,
	tc tells me unknown qdisc
Date: Tue, 11 Apr 2006 11:16:44 -0700
Message-ID: <20060411111644.59573edc@localhost.localdomain>
References: <1707.128.2.140.234.1144719699.squirrel@128.2.140.234>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: "George P Nychis" <gnychis@cmu.edu>
In-Reply-To: <1707.128.2.140.234.1144719699.squirrel@128.2.140.234>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

On Mon, 10 Apr 2006 21:41:39 -0400 (EDT)
"George P Nychis" <gnychis@cmu.edu> wrote:

> Hi,
> 
> I am trying to install a proprietary qdisc made for research, it is not publically released yet, however its been used several times so i know it works.
> 
> The files included are:
> q_xcp.c:
>    static int xcp_parse_opt()
>    static int xcp_print_opt()
>    static int xcp_print_xstats()
>    struct qdisc_util xcp_util = { "NULL", "xcp" ..... };
> 
> sch_xcp.c:
>    static int xcp_enqueue()
>    static int xcp_requeue()
>    static struct sk_buff * xcp_dequeue()
>    ....
>    ....
>    struct Qdisc_ops xcp_qdisc_ops ={ NULL,NULL,"xcp",.... };
> 
>    printk(KERN_INFO "XCP qdisc module loaded.\n");
>    return register_qdisc(&xcp_qdisc_ops);
> 
> 
> So, i make everything successfully, it creates q_xcp.so and copies it to /usr/lib and sch_xcp.o which it copies to /lib/modules/... so then I "insmod sch_xcp" and i see in dmesg:
> "XCP qdisc module loaded."
> 
> I then try:
> "tc qdisc add dev eth0 root xcp capacity 10Mbit limit 500" and get:
> "Unknown qdisc "xcp", hence option "capacity" is unparsable"
> 
> So then I read the INSTALL further to find some sort of solution and it mentions:
> This again assumes "tc" version is 2.4.7.  If your "tc" is a different
> version, download the iproute2 source code, and edit Makefile to
> point "TC_INCLUDE" to "-I..../iproute2/include -I..../iproute2/tc"
> 
> So, i did that, and i recompiled the q_xcp.so:
> lanthanum-ini src-1.0.1 # make q_xcp.so
> cc -O2 -fPIC -I/var/tmp/portage/iproute2-2.6.11.20050310-r1/work/iproute2-2.6.11/include/ -I/var/tmp/portage/iproute2-2.6.11.20050310-r1/work/iproute2-2.6.11/tc_include -o q_xcp.o -c q_xcp.c
> ld -shared -o q_xcp.so q_xcp.o
> rm -f q_xcp.o
> 
> But i still get the same error.... so then my very final last effort was to move q_xcp.c to my iproute2 source code tc/ directory and added this to the makefile:
> TCMODULES += q_xcp.o
> 
> Then I compiled tc, and i check tc to see if the xcp qdisc functions were loaded:
> lanthanum-ini tc # nm tc | grep xcp
> 080531ec t xcp_parse_opt
> 080533e0 t xcp_print_opt
> 08053426 t xcp_print_xstats
> 08070cc0 D xcp_util
> 
> And finally:
> lanthanum-ini tc # ./tc qdisc add dev ath0 root xcp capacity 54Mbit limit 500
> Unknown qdisc "xcp", hence option "capacity" is unparsable
> 
> 
> I have no clue :(  I figured that putting the .so into /usr/lib would have been enough.  Sorry for the long e-mail, I hope someone can help, and thank you for your time even if you don't know the solution but read this :)
> 
> - George
> 

The .so needs to go in /usr/lib/tc (assuming you are running relatively recent version
of iproute2 tools).

Read source to tc.c where it calls dlopen.
