From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] bridge: vlan: allow to suppress
 local mac install for all vlans
Date: Tue, 25 Aug 2015 17:56:27 -0700
Message-ID: <20150825175627.66ca9f30@urahara>
References: <1440549295-3979-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netdev@vger.kernel.org, wkok@cumulusnetworks.com, davem@davemloft.net
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1440549295-3979-1-git-send-email-razor@blackwall.org>
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

On Tue, 25 Aug 2015 17:34:55 -0700
Nikolay Aleksandrov <razor@blackwall.org> wrote:

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch adds a new knob that, when enabled, allows to suppress the
> installation of local fdb entries in newly created vlans. This could
> pose a big scalability issue if we have a large number of ports and a
> large number of vlans, e.g. in a 48 port device with 2000 vlans these
> entries easily go up to 96000.
> Note that packets for these macs are still received properly because they
> are added in vlan 0 as "own" macs and referenced when fdb lookup by vlan
> results in a miss.
> Also note that vlan membership of ingress port and the bridge device
> as egress are still being correctly enforced.
> 
> The default (0/off) is keeping the current behaviour.
> 
> Based on a patch by Wilson Kok (wkok@cumulusnetworks.com).


This is getting messy, but then again the bridge seems to have become
a ghetto for a long time. I would rather see the lookup code fixed so
that the fdb was correct.
