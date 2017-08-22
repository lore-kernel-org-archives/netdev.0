From: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v5] openvswitch: enable NSH support
Date: Wed, 23 Aug 2017 06:26:25 +0800
Message-ID: <201708230651.E6RQiLeI%fengguang.wu@intel.com>
References: <1503294863-12859-1-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, e@erig.me,
	kbuild-all-JC7UmRfGjtg@public.gmane.org
To: Yi Yang <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1503294863-12859-1-git-send-email-yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Yi,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Yi-Yang/openvswitch-enable-NSH-support/20170822-184251
config: x86_64-randconfig-a0-08230538 (attached as .config)
compiler: gcc-4.4 (Debian 4.4.7-8) 4.4.7
reproduce:
        # save the attached .config to linux build tree
        make ARCH=x86_64 

All warnings (new ones prefixed by >>):

   net//openvswitch/flow.c: In function 'parse_nsh':
>> net//openvswitch/flow.c:498: warning: unused variable 'err'

vim +/err +498 net//openvswitch/flow.c

   493	
   494	static int parse_nsh(struct sk_buff *skb, struct sw_flow_key *key)
   495	{
   496		struct nsh_hdr *nsh = (struct nsh_hdr *)skb_network_header(skb);
   497		u8 version, length;
 > 498		int err;
   499	
   500		if (unlikely(skb->len < NSH_BASE_HDR_LEN))
   501			return -EINVAL;
   502	
   503		version = nsh_get_ver(nsh);
   504		length = nsh_hdr_len(nsh);
   505	
   506		if (version != 0)
   507			return -EINVAL;
   508	
   509		if (unlikely(skb->len < length))
   510			return -EINVAL;
   511	
   512		key->nsh.flags = nsh_get_flags(nsh);
   513		key->nsh.ttl = nsh_get_ttl(nsh);
   514		key->nsh.mdtype = nsh->md_type;
   515		key->nsh.np = nsh->next_proto;
   516		key->nsh.path_hdr = nsh->path_hdr;
   517		switch (key->nsh.mdtype) {
   518		case NSH_M_TYPE1:
   519			if (length != NSH_M_TYPE1_LEN)
   520				return -EINVAL;
   521			memcpy(key->nsh.context, nsh->md1.context,
   522			       sizeof(nsh->md1));
   523			break;
   524		case NSH_M_TYPE2:
   525			/* Don't support MD type 2 metedata parsing yet */
   526			if (length < NSH_BASE_HDR_LEN)
   527				return -EINVAL;
   528	
   529			memset(key->nsh.context, 0,
   530			       sizeof(nsh->md1));
   531			break;
   532		default:
   533			return -EINVAL;
   534		}
   535	
   536		return 0;
   537	}
   538	

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--WIyZ46R2i8wDzkSu--
