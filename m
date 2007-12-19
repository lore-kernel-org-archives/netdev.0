From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH netns-2.6.25 0/19] routing virtualization
Date: Wed, 19 Dec 2007 18:21:51 +0300
Message-ID: <4769370F.5020303@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Benjamin Thery <benjamin.thery-6ktuUTfB/bM@public.gmane.org>, xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Hi, David!

This set adds namespace support for routing tables & rules manipulation
in the different namespaces. So, one could create a namespace and
setup IPv4 routing there how he wants.

After this patch user will have the ability to configure and
observe its own isolated set of routing rules/tables, but they
all will be unused. I.e. routing decisions inside the network
stack are still made based on the init_net's rules. The reason for doing
so is to have something self-consistent and not too huge :)

The sequence is the following:
- viritualize generic FIB rules operations
- change IPv4 FIB initialization sequence
- virtualize FIB tables access

After this, the 'ip' utility and the /proc interface will start
working correctly inside a namespace, while the 'route' utility
will not, because IP sockets currently cannot be created in non-init
namespace.

Regards,
	Den
