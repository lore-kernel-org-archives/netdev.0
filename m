From: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 5/5] net: Add Open vSwitch kernel
	components.
Date: Mon, 21 Nov 2011 15:25:18 -0800
Message-ID: <20111121152518.79e82eb8@nehalam.linuxnetplumber.net>
References: <1321911029-20707-1-git-send-email-jesse@nicira.com>
	<1321911029-20707-6-git-send-email-jesse@nicira.com>
	<20111121135955.571254b1@nehalam.linuxnetplumber.net>
	<CAEP_g=8uoq7tJjUTAC_Sp3kOYwZJuKjD3J7Ratu67Kq56ZiyYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CAEP_g=8uoq7tJjUTAC_Sp3kOYwZJuKjD3J7Ratu67Kq56ZiyYA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Nov 2011 15:18:43 -0800
Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:

> On Mon, Nov 21, 2011 at 1:59 PM, Stephen Hemminger
> <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> wrote:
> > On Mon, 21 Nov 2011 13:30:29 -0800
> > Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org> wrote:
> >
> >> +/**
> >> + * =A0 vport_record_error - indicate device error to generic stats la=
yer
> >> + *
> >> + * @vport: vport that encountered the error
> >> + * @err_type: one of enum vport_err_type types to indicate the error =
type
> >> + *
> >> + * If using the vport generic stats layer indicate that an error of t=
he given
> >> + * type has occured.
> >> + */
> >> +void vport_record_error(struct vport *vport, enum vport_err_type err_=
type)
> >> +{
> >> + =A0 =A0 spin_lock(&vport->stats_lock);
> >
> > Sorry for over analyzing this... but I don't think the stats_lock
> > is necessary either. The only thing it is protecting is against 64 bit
> > wrap. If you used another u64_stat_sync for that one, it could be elimi=
nated.
> >
> > Maybe?
> =

> The reason for stats_lock is that the error stats are not expected to
> be contended so in order to save some memory they're not per-cpu and
> we just use a spin lock to protect them.

Assignment or increment of native type size (64 bit on 64 bit cpu)
is always atomic.
