From: Mark Seaborn <mrs-ChQETwBkFSdCgCasaBwmdgC/G2K4zDHf@public.gmane.org>
Subject: Re: Network isolation with RLIMIT_NETWORK, cont'd.
Date: Thu, 17 Dec 2009 17:31:23 +0000
Message-ID: <fb69ef3c0912170931l5cbf0e3dh81c88e6502651042@mail.gmail.com>
References: <m1ljh7jijk.fsf@fess.ebiederm.org> <20091213142149.GB4777@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Lang <david-gFPdbfVZQbY@public.gmane.org>, Valdis Kletnieks <Valdis.Kletnieks-PjAqaU27lzQ@public.gmane.org>,
        Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "C. Scott Ananian" <cscott-FML+fnLth/WsTnJN9+BGXg@public.gmane.org>,
        Bernie Innocenti <bernie-+SBua99wBSpAfugRpC6u6w@public.gmane.org>,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Evgeniy Polyakov <zbr-i6C2adt8DTjR7s880joybQ@public.gmane.org>, Bryan Donlan <bdonlan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        =?ISO-8859-1?Q?R=E9mi_Denis=2DCourmont?= <rdenis-uaTwlBVGafag2h7rfAr7Vg@public.gmane.org>,
        Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
To: Michael Stone <michael-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20091213142149.GB4777@heat>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 13, 2009 at 2:21 PM, Michael Stone <michael-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org> wrote:

> For comparison, I do use CLONE_NEWNS mount namespaces and they've been a
> real
> pain because
>
>  a) unlike in Plan 9, they're privileged,
>
>  b) they greatly complicate debugging the isolated app because you see
>     different things inside and outside the namespace,
>
>  c) there's no good way to manipulate them from userland, and
>
>  d) they're poorly documented outside of the mount man page.
>

Maybe we could try to fix those problems.

The reason chroot() and clone()/CLONE_NEWNS are privileged is that they
provide a way to violate the assumptions of setuid/setgid executables.  If
we add a per-process flag that prevents a process from exec'ing setuid
executables, we could allow chroot() and CLONE_NEWNS when that flag is set.
That fixes (a).

Maybe we could fix (b) by making mount namespaces into first class objects
that can be named through a file descriptor, so that one process can
manipulate another process's namespace without itself being subject to the
namespace.

Cheers,
Mark
