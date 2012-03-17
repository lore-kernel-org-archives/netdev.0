From: Nix <nix@esperi.org.uk>
Subject: Re: e1000e interface hang on 82574L
Date: Sat, 17 Mar 2012 23:50:51 +0000
Message-ID: <87k42izt0k.fsf@spindle.srvr.nix>
References: <4EFA4024.5000909@bootc.net>
	<FCF3184D-CE4F-471C-B66C-0F671795FD3C@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B626017762@ORSMSX102.amr.corp.intel.com>
	<4F048861.8070501@bootc.net> <4F12B42C.9030803@bootc.net>
	<9BBC4E0CF881AA4299206E2E1412B62621F0B1@ORSMSX102.amr.corp.intel.com>
	<4F144A76.3050703@bootc.net> <4F64B4E2.20208@bootc.net>
	<4F64CFCB.7060702@bootc.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>, lkml <linux-kernel@vger.kernel.org>
To: Chris Boot <bootc@bootc.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4F64CFCB.7060702@bootc.net> (Chris Boot's message of "Sat, 17
	Mar 2012 17:54:19 +0000")
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 17 Mar 2012, Chris Boot verbalised:
> Most notably it appears as though MSI-X is not enabled on the 
> Supermicro, and ASPM L1 is. There appears to be no difference on the 
> Supermicro as to the MSI-X status when booting with IntMode=1,1 compared 
> to without it.

This bug is an ASPM bug, not an MSI bug, and has been present in the
in-kernel drivers since something like 2.6.36. I reported it a rather
long time ago to the e1000e bugzilla:
<http://sourceforge.net/tracker/index.php?func=detail&aid=3170405&group_id=42302&atid=447449>
but then I got a severe attack of forgetfulness and forgot what bz it
was on until this post prodded me into finding it again. (And then
kernel.org was penetrated and I didn't even bother looking, because of
course I reported it to the offlined kernel bz, right? No, I didn't.)

I really should follow up on it now and ask the kernel PCI hackers to
suggest reasons why ASPM might be getting magically re-enabled at around
the same time as the interface is brought up. (Disabling ASPM via setpci
at boot doesn't help if the interface hasn't stabilized before that
point.)

I haven't done much printf()-scattering to try to track it down because
rebooting this machine is quite annoying: it's the heart of my network,
my damn-near-everything-server and the machine on which all my work
virtual machines run, so rebooting it means disappearing from work for
some time while the reboot happens... (but of course this is a really
pathetic excuse because I could have devoted a weekend to it or
something. So add laziness to my sins.)


So currently I'm doing

setpci -s 02:00.0 CAP_EXP+10.b=40
setpci -s 03:00.0 CAP_EXP+10.b=40

in a root shell to force ASPM off on my two 82574Ls after every boot. It
is quite annoying, but 'solves' the problem (for a very crap value of
'solves').

-- 
NULL && (void)

------------------------------------------------------------------------------
This SF email is sponsosred by:
Try Windows Azure free for 90 days Click Here 
http://p.sf.net/sfu/sfd2d-msazure
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
