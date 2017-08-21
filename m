From: Jan Scheurich <jan.scheurich-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH net-next v4] openvswitch: enable NSH support
Date: Mon, 21 Aug 2017 09:31:27 +0000
Message-ID: <CFF8EF42F1132E4CBE2BF0AB6C21C58D7274A53E@ESESSMB107.ericsson.se>
References: <1503041071-68753-1-git-send-email-yi.y.yang@intel.com>
	<20170818152601.3760aaec@griffin>
	<20170821061109.GA72656@cran64.bj.intel.com>
	<20170821101925.3f9b36a1@griffin>
	<20170821083900.GA74649@cran64.bj.intel.com>
	<CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3@ESESSMB107.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org'" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
	"'netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org'" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"'e@erig.me'" <e@erig.me>
To: "'Yang, Yi'" <yi.y.yang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, 'Jiri Benc' <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <ovs-dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <CFF8EF42F1132E4CBE2BF0AB6C21C58D727494F3-hqolJogE5njKJFWPz4pdheaU1rCVNFv4@public.gmane.org>
Content-Language: en-US
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

> 
> The second member of the union should be a variable length array [] of
> struct nsh_md2_tlv
> 
> struct nsh_hdr {
>     ovs_be16 ver_flags_ttl_len;
>     uint8_t mdtype;
>     uint8_t np;
>     ovs_16aligned_be32 path_hdr;
>     union {
>         struct nsh_md1_ctx md1;
>         struct nsh_md2_tlv md2[];
>     };
> };
> 
> That was the original design before Ben removed it due to missing support
> in Microsoft compiler.
> For the Kernel datapath we should go back to that.
> 
> I wonder about the possible 16-bit alignment of the 32-bit fields, though.
> How is that handled in the kernel? Also struct nsh_md1_ctx has 32-bit
> members, which might not be 32-bit aligned in the packet.
> 

One afterthought: 

I think it would be good to add another member to the union to represent unstructured context headers as used, e.g., in the context of push_nsh.

struct nsh_hdr {
    ovs_be16 ver_flags_ttl_len;
    uint8_t mdtype;
    uint8_t np;
    ovs_16aligned_be32 path_hdr;
    union {
        uint8_t ctx_headers[];
        struct nsh_md1_ctx md1;
        struct nsh_md2_tlv md2[];
    };
};
