From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [Fastboot] Re: Re: tg3: issue for reboot/kexec
Date: Thu, 18 Aug 2005 12:42:05 -0600
Message-ID: <m1wtmjulxe.fsf@ebiederm.dsl.xmission.com>
References: <42BC9F09.1060002@us.ibm.com>
	<20050624174652.159f26ce.rdunlap@xenotime.net>
	<20050625033328.GC3934@kroah.com>
	<m18y0rl9bq.fsf@ebiederm.dsl.xmission.com>
	<20050630233354.GA22287@kroah.com>
	<m1vf3vjtbc.fsf@ebiederm.dsl.xmission.com>
	<1124389821.2274.11.camel@lyra.fc.hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============23833782042961249=="
Cc: linux-pm@lists.osdl.org, Fastboot mailing list <fastboot@lists.osdl.org>,
   netdev@vger.kernel.org
Return-path: <linux-pm-bounces@lists.osdl.org>
To: Khalid Aziz <khalid_aziz@hp.com>
In-Reply-To: <1124389821.2274.11.camel@lyra.fc.hp.com> (Khalid Aziz's
	message of "Thu, 18 Aug 2005 12:30:21 -0600")
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/linux-pm>
List-Post: <mailto:linux-pm@lists.osdl.org>
List-Help: <mailto:linux-pm-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/linux-pm>,
	<mailto:linux-pm-request@lists.osdl.org?subject=subscribe>
Sender: linux-pm-bounces@lists.osdl.org
Errors-To: linux-pm-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============23833782042961249==
Content-Type: text/plain; charset=us-ascii

Khalid Aziz <khalid_aziz@hp.com> writes:

> On Thu, 2005-06-30 at 17:52 -0600, Eric W. Biederman wrote:
>
> I have found that I can not walk reboot_notifier list in all cases
> before kexec'ing a new kernel. For instance, when handling INIT on ia64,
> we are running in interrupt context and atleast some of the reboot
> notifier callbacks call schedule(). Calling schedule() is not gonna work
> when we are running in interrupt context. I have the same concern for
> when panic gets called in interrupt context. So I added a shutdown
> function to e1000 driver instead. Patch is attached. This patch has
> worked for me.

Thanks.  I will look at your e1000 driver and see if it works on
the hardware I have here.  You changes are at least to places
that could have fixed the problem I am seeing.

For the panic case calling any of the shutdown/reboot notifier bits
is actually wrong.  That kernel that takes over needs to cope with
hardware left in any state.

> As soon as I have all the issues sorted out with kexec'ing on INIT on
> ia64, I will post a fully updated kexec patch for ia64. I now have kexec
> working solid on INIT with e1000 driver and it can handle multiple back
> to back INITs and come up in kexec'd kernel every time. I am now trying
> to sort some issues out with tg3 driver (another driver with no shutdown
> routine :(

In the normal case (not kexec on panic) user space should down the interfaces
before calling kexec.  Is your user space doing that?


Eric

--===============23833782042961249==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline


--===============23833782042961249==--
