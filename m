From: Fan Du <fan.du@windriver.com>
Subject: [PATCH net-next 0/2] Pack struct xfrm_usersa_info
	and struct xfrm_userpolicy_info
Date: Tue, 7 Jan 2014 14:48:57 +0800
Message-ID: <1389077339-12814-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org, davem@davemloft.net,
	dev@lists.strongswan.org
To: <steffen.klassert@secunet.com>
Return-path: <dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org>
List-Unsubscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=unsubscribe>
List-Archive: <http://lists.strongswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.strongswan.org>
List-Help: <mailto:dev-request@lists.strongswan.org?subject=help>
List-Subscribe: <https://lists.strongswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.strongswan.org?subject=subscribe>
Sender: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
Errors-To: dev-bounces+gnvsd-dev=m.gmane.org@lists.strongswan.org
List-Id: netdev.vger.kernel.org

When trying to setup IPsec configuration on a 64bits host with
iproute2(32bits compiled), the intened xfrm policy and sa is
either deficit or wrong when kernel trying to parse user land
information.

Further investigatino shows that:
L: kernel
R: iproute2

          sizeof       userpolicy      usersa
64bits(unpacked)        168/168        224/224
32bits(unpacked)        164/164        220/220
                         ^   ^
                         L   R

To keep kernel and user land see a consistent structure, after
add packing attribute, now it looks like this:

64bits(  packed)        164/164        217/217
32bits(  packed)        164/164        217/217
                         ^   ^
                         L   R

Then different kernel/iproute2 build configuration will not impact IPsec setup.

Fan Du (2):
  include/uapi/linux/xfrm.h: Pack struct xfrm_userpolicy_info
  include/uapi/linux/xfrm.h: Pack struct xfrm_usersa_info

 include/uapi/linux/xfrm.h |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

-- 
1.7.9.5
