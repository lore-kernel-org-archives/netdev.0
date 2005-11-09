From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: RED qdisc not working...
Date: Wed, 9 Nov 2005 23:32:58 +0000
Message-ID: <6278d2220511091532k7b732b9bv2957763ba6f4c10f@mail.gmail.com>
References: <6278d2220511071626j3646afa7n5ac33228e8b3fc82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: davem@redhat.com, laforge@netfilter.org, coreteam@netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org,
        netfilter@lists.netfilter.org, kaber@trash.net
In-Reply-To: <6278d2220511071626j3646afa7n5ac33228e8b3fc82@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Has anyone been able to get the RED (random early detection) qdisc
working lately?

I can't get anything going through it to be dropped or marked; the
'marked', 'early', 'pdrop' and 'other' fields remain at 0 [1]. In my
example script [2], I get the 3072Kbits/s transfer into eth0, which
you'd only expect if the RED qdisc wasn't there.

I have tried with a recent 2.6.12 debian kernel and stock 2.6.14 on
x86_64 debian. I rebuilt new iproute and iptables packages from latest
clean upstream sources, but to no avail.

Any ideas? Please CC me on replies, as I am not subscribed.

Thanks,
  Dan

--- [1]

# tc -s qdisc show dev eth0
qdisc htb 1: r2q 10 default 10 direct_packets_stat 0
 Sent 53985530 bytes 36757 pkts (dropped 0, overlimits 45125)
qdisc red 10: parent 1:10 limit 512Kb min 64Kb max 128Kb
 Sent 53985530 bytes 36757 pkts (dropped 0, overlimits 0)
  marked 0 early 0 pdrop 0 other 0

--- [2]

tc qdisc del dev eth0 root

tc qdisc add dev eth0 root handle 1: htb default 10
tc class add dev eth0 parent 1: classid 1:1 htb rate 4096kbit ceil 4096kbit
tc class add dev eth0 parent 1:1 classid 1:10 htb rate 3072kbit ceil 3072kbit
tc qdisc add dev eth0 parent 1:10 handle 10: red \
  limit 4096kbit min 512kbit max 1024kbit avpkt 1000 \
  burst 100 probability 0.02 bandwidth 1024kbit
___
Daniel J Blueman
