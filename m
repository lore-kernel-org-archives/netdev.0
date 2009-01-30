From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 10:27:49 +0000
Message-ID: <20090130102749.GC1052@redhat.com>
References: <20090128212114.38be3e8c@extreme>
	<20090129103544.GC22110@redhat.com>
	<20090129213549.7fadfa2e@extreme>
	<20090130081600.GA2717@ioremap.net>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Fedora/Linux Management Tools <et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Fedora/Linux Management Tools <et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
Return-path: <et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090130081600.GA2717-i6C2adt8DTjR7s880joybQ@public.gmane.org>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/et-mgmt-tools>
List-Post: <mailto:et-mgmt-tools-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Help: <mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/et-mgmt-tools>,
	<mailto:et-mgmt-tools-request-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org?subject=subscribe>
Sender: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Errors-To: et-mgmt-tools-bounces-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 30, 2009 at 11:16:00AM +0300, Evgeniy Polyakov wrote:
> Hi.
> 
> On Thu, Jan 29, 2009 at 09:35:49PM -0800, Stephen Hemminger (shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org) wrote:
> > > > This is probably related to the new GEM code. But on 2.6.29-rc2 if I start up the virtual
> > > > machine manager then run a guest, the display gets screwed up.
> > > > 
> > > > virt-machine-manager
> > > >   click local-host (System)
> > > >   Run one of the existing VM's
> > > >  
> > > > The virtual console window then cause a dialog about allowing remote access to display;
> > > > (this never happened with earlier kernels), regression #1
> > > > 
> > > > Then if I allow it multiple copies of the window start cloning and general chaos ensues.
> > > 
> > > You'll have to provide more useful information than 'screwed up' and
> > > 'general choas' if we're to properly dianose this. A screenshot of what
> > > is wrong if there's a graphics rendering problem would be a start.
> > > 
> > > Also, what GTK-VNC version do you have ?  Make sure it is at least
> > > 0.3.8, so that it is using Cairo for rendering, and not old buggy
> > > OpenGL based GtkGLExt.
> > > 
> > > Daniel
> > 
> > The problem is only in the net-next tree (not mainline 2.6.29-rcX).
> > Bisected down to this commit is the problem:
> > 
> > a9d8f9110d7e953c2f2b521087a4179677843c2a is first bad commit
> > commit a9d8f9110d7e953c2f2b521087a4179677843c2a
> > Author: Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>
> > Date:   Mon Jan 19 16:46:02 2009 -0800
> 
> Any chance to get a bit more information about what this console does?

The virt-manager console is basically just a plain old boring VNC client.
It uses GTK-VNC to establish its VNC network connection, and that doesn't
do anything unusual AFAIK. We use getaddrinfo() to resolve the hostname,
and then try each of its results in turn, until we succesfully connect
to the VNC server. We don't explicitly bind() to the client port, just
let the kernel pick it for us. The code in question, is the "gvnc_open_host"
method from gvnc.c,  which starts at about line 2910

http://freehg.org/u/aliguori/gtk-vnc.hg/file/d68935d582f0/src/gvnc.c

Regards,
Daniel 
-- 
|: Red Hat, Engineering, London   -o-   http://people.redhat.com/berrange/ :|
|: http://libvirt.org  -o-  http://virt-manager.org  -o-  http://ovirt.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: GnuPG: 7D3B9505  -o-  F3C9 553F A1DA 4AC2 5648 23C1 B3DF F742 7D3B 9505 :|
