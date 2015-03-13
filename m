From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: Zero the tuple in nfnl_cthelper_parse_tuple()
Date: Fri, 13 Mar 2015 12:08:48 +0100
Message-ID: <20150313110848.GA5818@salvia>
References: <1426153078-20863-1-git-send-email-iwilson@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Ian Wilson <iwilson@brocade.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426153078-20863-1-git-send-email-iwilson@brocade.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 12, 2015 at 09:37:58AM +0000, Ian Wilson wrote:
> nfnl_cthelper_parse_tuple() is called from nfnl_cthelper_new(),
> nfnl_cthelper_get() and nfnl_cthelper_del().  In each case they pass
> a pointer to an nf_conntrack_tuple data structure local variable:
> 
>     struct nf_conntrack_tuple tuple;
>     ...
>     ret = nfnl_cthelper_parse_tuple(&tuple, tb[NFCTH_TUPLE]);
> 
> The problem is that this local variable is not initialized, and
> nfnl_cthelper_parse_tuple() only initializes two fields: src.l3num and
> dst.protonum.  This leaves all other fields with undefined values
> based on whatever is on the stack:
> 
>     tuple->src.l3num = ntohs(nla_get_be16(tb[NFCTH_TUPLE_L3PROTONUM]));
>     tuple->dst.protonum = nla_get_u8(tb[NFCTH_TUPLE_L4PROTONUM]);
> 
> The symptom observed was that when the rpc and tns helpers were added
> then traffic to port 1536 was being sent to user-space.

Applied, thanks. I'll pass this to -stable too.
