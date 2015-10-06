From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: allow adding of fdb entries pointing
 to the bridge device
Date: Tue, 06 Oct 2015 08:55:55 -0700
Message-ID: <5613EF0B.8070901@cumulusnetworks.com>
References: <201510062313.0dtpdZ0k%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, davem@davemloft.net, netdev@vger.kernel.org,
	nikolay@cumulusnetworks.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34252 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751460AbbJFPz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 11:55:57 -0400
Received: by padhy16 with SMTP id hy16so73870016pad.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 08:55:56 -0700 (PDT)
In-Reply-To: <201510062313.0dtpdZ0k%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/6/15, 8:29 AM, kbuild test robot wrote:
> Hi Roopa,
>
> [auto build test WARNING on next-20151006 -- if it's inappropriate base, please ignore]
>
> config: sh-titan_defconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=sh 
>
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
>
> All warnings (new ones prefixed by >>):
>
>    net/bridge/br_fdb.c: In function 'br_fdb_add':
>>> net/bridge/br_fdb.c:784:13: warning: 'p' may be used uninitialized in this function [-Wuninitialized]
>    net/bridge/br_fdb.c:850:26: note: 'p' was declared here
>    net/bridge/br_fdb.c: In function 'br_fdb_delete':
>    net/bridge/br_fdb.c:952:11: warning: 'p' may be used uninitialized in this function [-Wuninitialized]
>    net/bridge/br_fdb.c:977:26: note: 'p' was declared here
>
> vim +/p +784 net/bridge/br_fdb.c
>
> eb8d7baa Wilson Kok        2015-05-25  768  
> 2ba071ec Vlad Yasevich     2013-02-13  769  	fdb = fdb_find(head, addr, vid);
> 64af1bac stephen hemminger 2011-09-30  770  	if (fdb == NULL) {
> 64af1bac stephen hemminger 2011-09-30  771  		if (!(flags & NLM_F_CREATE))
> 64af1bac stephen hemminger 2011-09-30  772  			return -ENOENT;
> 36fd2b63 stephen hemminger 2011-04-04  773  
> 2ba071ec Vlad Yasevich     2013-02-13  774  		fdb = fdb_create(head, source, addr, vid);
> 36fd2b63 stephen hemminger 2011-04-04  775  		if (!fdb)
> 36fd2b63 stephen hemminger 2011-04-04  776  			return -ENOMEM;
> b0a397fb roopa             2013-04-22  777  
> b0a397fb roopa             2013-04-22  778  		modified = true;
> 64af1bac stephen hemminger 2011-09-30  779  	} else {
> 64af1bac stephen hemminger 2011-09-30  780  		if (flags & NLM_F_EXCL)
> 64af1bac stephen hemminger 2011-09-30  781  			return -EEXIST;
> b0a397fb roopa             2013-04-22  782  
> b0a397fb roopa             2013-04-22  783  		if (fdb->dst != source) {
> b0a397fb roopa             2013-04-22 @784  			fdb->dst = source;
> b0a397fb roopa             2013-04-22  785  			modified = true;
> b0a397fb roopa             2013-04-22  786  		}
> 64af1bac stephen hemminger 2011-09-30  787  	}
> 36fd2b63 stephen hemminger 2011-04-04  788  
> 0e29720e Roopa Prabhu      2015-10-06  789  	if (fdb_to_nud(br, fdb) != state) {
> 145beee8 Vlad Yasevich     2014-05-16  790  		if (state & NUD_PERMANENT) {
> 145beee8 Vlad Yasevich     2014-05-16  791  			fdb->is_local = 1;
> 145beee8 Vlad Yasevich     2014-05-16  792  			if (!fdb->is_static) {
>
>
It is not used when it is not initialized. But I will resubmit the patch by initializing it to NULL (thanks nikolay for the suggestion).

Thanks.
