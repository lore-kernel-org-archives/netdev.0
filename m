From: Pedro Ramalhais <ramalhais@serrado.net>
Subject: Wireless Extensions WE-18 questions
Date: Sun, 08 Aug 2004 02:36:40 +0100
Sender: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
Message-ID: <1091929000.2800.12.camel@rootix>
References: <1091444633.2767.8.camel@rootix> <20040803070843.GB7153@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jt@hpl.hp.com, netdev@oss.sgi.com, hostap@shmoo.com
Return-path: <hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com>
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20040803070843.GB7153@jm.kir.nu>
List-Unsubscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=unsubscribe>
List-Archive: <http://sisyphus.iocaine.com/pipermail/hostap>
List-Post: <mailto:hostap@shmoo.com>
List-Help: <mailto:hostap-request@shmoo.com?subject=help>
List-Subscribe: <http://lists.shmoo.com/mailman/listinfo/hostap>,
	<mailto:hostap-request@shmoo.com?subject=subscribe>
Errors-To: hostap-bounces+gldh-hostap-597=gmane.org@shmoo.com
List-Id: netdev.vger.kernel.org

Hi Jouni!
Since you're the author of the WE-18 patch proposal i have a few
questions about it:

- what kind of information should be used in set_genie/get_genie
requests? I know it's a pointer, but what is the information it points
to? ipw2100 firmware expects: capabilities, listening interval,
current_ap, var_ie_len and var_ie for setting IEs.

- How should IW_AUTH_CIPHER_PAIRWISE and IW_AUTH_CIPHER_GROUP be used
with crypt_tkip/crypt_ccmp ?

This one is more oriented to the design of the wireless extensions and
should probably go to Jean Tourrilhes:
- the switch/case logic (for set_auth/get_auth at least) should really
be in the wireless extensions. The driver should only need to set
function pointers to the required actions, otherwise, every driver will
have to code the whole logic around the multiplexing of the IOCTL,
requiring more work amongst drivers, and the code will get less
readable. Maybe this could be done also to the rest of the wireless
extensions. I simply cannot understand the reason why the IOCTL
interface is exposed to the driver. The driver shouldn't even know that
some functionality is being called from an IOCTL. From the wireless
extensions point of view the driver should only provide the methods to
do certain tasks, not the logics around the passing of information from
userspace(ex: wireless tools) to kernel space(wireless extensions) this
just duplicates driver work.

Thanks!

PS: I was hoping someone had already answer my e-mail about the creation
of a linux wireless mailing list, and this message would be sent to the
new list... oh well
-- 
Pedro Ramalhais <ramalhais@serrado.net>
