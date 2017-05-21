From: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4.4-only] openvswitch: clear sender cpu before
 forwarding packets
Date: Sun, 21 May 2017 16:47:36 +0800
Message-ID: <201705211641.mxT5Z8Ag%fengguang.wu@intel.com>
References: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kbuild-all-JC7UmRfGjtg@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Anoob Soman <anoob.soman-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1494944710-7901-1-git-send-email-anoob.soman-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://mail.openvswitch.org/mailman/options/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://mail.openvswitch.org/pipermail/ovs-dev/>
List-Post: <mailto:ovs-dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <https://mail.openvswitch.org/mailman/listinfo/ovs-dev>,
	<mailto:ovs-dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Anoob,

[auto build test ERROR on v4.9-rc8]
[also build test ERROR on next-20170519]
[if your patch is applied to the wrong git tree, please drop us a note to help improve the system]

url:    https://github.com/0day-ci/linux/commits/Anoob-Soman/openvswitch-clear-sender-cpu-before-forwarding-packets/20170519-111009
config: x86_64-rhel (attached as .config)
compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All errors (new ones prefixed by >>):

   net/openvswitch/vport.c: In function 'ovs_vport_send':
>> net/openvswitch/vport.c:513:2: error: implicit declaration of function 'skb_sender_cpu_clear' [-Werror=implicit-function-declaration]
     skb_sender_cpu_clear(skb);
     ^~~~~~~~~~~~~~~~~~~~
   cc1: some warnings being treated as errors

vim +/skb_sender_cpu_clear +513 net/openvswitch/vport.c

   507					     packet_length(skb), mtu);
   508			vport->dev->stats.tx_errors++;
   509			goto drop;
   510		}
   511	
   512		skb->dev = vport->dev;
 > 513		skb_sender_cpu_clear(skb);
   514		vport->ops->send(skb);
   515		return;
   516	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--y0ulUmNC+osPPQO6--
