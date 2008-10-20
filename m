From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i cannot
 navigate
Date: Mon, 20 Oct 2008 23:55:48 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810202323330.30254@wrl-59.cs.helsinki.fi>
References: <bug-11721-11547@http.bugzilla.kernel.org/>
 <20081020154737.2D0CA108042@picon.linux-foundation.org>
 <20081020171530.GA2564@ami.dom.local> <20081020214818.09d88b48@topolino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	Netdev <netdev@vger.kernel.org>
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53594 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbYJTUzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 16:55:50 -0400
In-Reply-To: <20081020214818.09d88b48@topolino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Oct 2008, Aldo Maggi wrote:

> i repeat here what i wrote there:
> 
> Ilpo,
> i'm sending herewith attached the output of
> tcpdump -i eth0 -nXX -c3 'dst port 80 and tcp-syn != 0' on topolino when:
> 1) kernel 2.6.26.6 is running on paperino and tcp_window_scaling,
> tcp_timestamps, tcp_sack are set to "1"
> 2) kernel 2.6.26.6 is running on paperino and tcp_window_scaling,
> tcp_timestamps, tcp_sack are set to "0"
> 3) kernel 2.6.27-rc1-git1 is running on paperino and tcp_window_scaling,
> tcp_timestamps, tcp_sack are set to "1"
> 4) kernel 2.6.27-rc1-git1 is running on paperino and tcp_window_scaling,
> tcp_timestamps, tcp_sack are set to "0"

Thanks, very unambiquously being told what each case is, helps a lot... :-)

Difference is: ip checksum, ipid, lsb of dstaddr, sport, seqno, tcp 
checksum, timestamp. Plus the option reordering as discussed before. Here 
are the options:

    28  0204  <
    29  05b4  <
    30  0402    0402
    31  080a    080a
    32  0019  | ffff
    33  db30  | 8169
    34  0000    0000
    35  0000    0000
    36        > 0204
    37        > 05b4
    38  0103    0103
    39  0306    0306

Could you try if tcp_window_scaling=1, tcp_sack=1, tcp_timestamps=0 also 
works, if you didn't already (it's not that obvious from the earlier 
acknowledgement you gave that these were the exact options you used or 
not)...

> moreover, i read more carefully what you and Jarek wrote above, please let me
> know if you deem still necessary that i apply the patch you provided and
> compile or if you like i compile the latest kernel or whatever.

If that ws=1,s=1,ts=0 test succeeds, then testing my patch would be useful 
too. Anyway it seems that we're dealing with some violation of spec here
(by either the peer or some middle node, 2.6.27-whatever is not doing 
something outside of spec), just trying to narrow down which of the 
options is the actual cause. We might need to try later some other 
ordering of options too to rule out possibilities by trial-and-error
(ie., unless you have a better knowledge about the devices on the path, 
information which I sort of expect to be out of (y)our reach :-)).


-- 
 i.
