From: Fabio Massimo Di Nitto <fabbione@fabbione.net>
Subject: Re: ipv6 stack seems to forget to send ACKs
Date: Wed, 8 Jan 2003 19:05:36 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.51.0301081849550.564@diapolon.int.fabbione.net>
References: <20030108130850.GQ22951@wiggy.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
In-Reply-To: <20030108130850.GQ22951@wiggy.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I was able to reproduce the problem again. I have been using ethereal to
sniff instead of tcpdump and gave out some more info.

basically the icecast server at certain time (but i can't predict
exactly in which situations) just send a FIN, ACK packet to the client.
Basically to close the connection and after a few packets the client of
course answer.What is strange that in the meanwhile there are still 3/4
data packets coming from the server to the client.

Regarding the network side I noticed the following:

an average of 500ms to ping6 the server and 0 pkt loss
few seconds before the FIN, ACK (server->client) and for about 6 pkts the
average jumped to 2000ms

I suspect that this network flap made the server thinking about
<insert_here_whatever_term_is_more_appropriate> and decided to close
the connection.

The full ethereal dump is available at
http://www.fabbione.net/ice-xmms-ipv6.dump.bz2

but PLEASE note that it is a 10MB file and Im on a slow adsl line so be
"nice".

Fabio

PS Im afraid/happy that anyway the problem is not related to the kernel
version we are running.

-- 
vega:~# apt-get install life
Reading Package Lists... Done
Building Dependency Tree... Done
E: Couldn't find package life
