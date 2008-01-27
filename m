From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: netatalk slow after system upgrade (possibly kernel problem?)
Date: Sat, 26 Jan 2008 22:00:51 -0800
Message-ID: <20080126220051.d753266b.akpm@linux-foundation.org>
References: <200801251255.48105@zmi.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netatalk-admins@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Monnerie <michael.monnerie@it-management.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39765 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbYA0GCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jan 2008 01:02:14 -0500
In-Reply-To: <200801251255.48105@zmi.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(cc netdev)

> On Fri, 25 Jan 2008 12:55:42 +0100 Michael Monnerie <michael.monnerie@it-management.at> wrote:
> Dear lists,
> 
> I've been spending a LOT of time trying to find out where's the problem, 
> but can't find it and therefore seek urgent help now. We have the 
> following system:
> 
> Server with VMware server
> -> VM running a webserver and netatalk
> -> 2 other VMs not related
> 
> The VM with netatalk was SUSE 10.0 with kernel 2.6.13-15.15-smp (from 
> SUSE), and things were pretty fun and quick. Then we upgraded to SUSE 
> 10.2 and now 10.3, where everything EXCEPT netatalk runs perfect. Since 
> this upgrade, Apple clients (MacOS X) now do READ very very slowly 
> (about 512KB/s over the gigabit LAN), while writing to the server still 
> is normal (>20MB/s). I've even retried with the newest kernel 
> 2.6.23.13, tried different /proc/sys/net/ipv4/tcp_congestion_control 
> (cubic, reno, bic, etc.) and nothing helps. I've then tried to install 
> Samba and found that we have similar problems reading with it from 
> MacOS clients. Now I'm pretty sure it should be something with the 
> linux kernel, but I don't understand what.
> 
> Here are the wireshark dumps in pcap format:
> http://zmi.at/x/atalk-write-fast.pcap
> -> you can see writing to the server (192.168.120.9) is normal and fast
> 
> http://zmi.at/x/atalk-read-slow.pcap
> -> reading is horribly slow. Lots of "unknown", because of netatalk or 
> what?
> 
> http://zmi.at/x/unknown-atalk.pcap
> -> another dump while reading, you see "unknown" reads. I'm not sure if 
> it's just wireshark not understanding the packets or netatalk.
> 
> And trying with samba:
> http://zmi.at/x/smb-read-slow.pcap
> http://zmi.at/x/smb-write-quick.pcap
> you can see that it's also slow.
> 
> Now why did it work with the old 2.6.13 kernel? I still have that old 
> VM, and when I start it, it is always perfectly fast. Only newer 
> versions are slow. Can somebody give me a hint please?

It would be interesting if this could be repeated on bare hardware, so we
can eliminate the possibility that it is some weird interaction with vmware.

