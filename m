From: Richard Weinberger <richard@nod.at>
Subject: user controllable usermodehelper in br_stp_if.c
Date: Sun, 29 Nov 2015 23:43:09 +0100
Message-ID: <565B7F7D.80208@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"keescook@chromium.org" <keescook@chromium.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Hi!

By spawning new network and user namesapces an unprivileged user
is able to execute /sbin/bridge-stp within the initial mount namespace
with global root rights.
While this cannot directly be used to break out of a container or gain
global root rights it could be used by exploit writers as valuable buildi=
ng block.

e.g.
$ unshare -U -r -n /bin/sh
$ brctl addbr br0
$ brctl stp br0 on # this will execute /sbin/bridge-stp

As this mechanism clearly cannot work with containers and seems to be leg=
acy code
I suggest not calling call_usermodehelper() at all if we're not in the in=
itial user namespace.
What do you think?

Thanks,
//richard
