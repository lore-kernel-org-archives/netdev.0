From: jamal <hadi@cyberus.ca>
Subject: Re: bridge between ppp and ethernet - 1 IP address and assign it
	to another host
Date: 09 Mar 2005 19:30:56 -0500
Message-ID: <1110414655.1109.56.camel@jzny.localdomain>
References: <Pine.LNX.4.58.0503092041400.17842@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, ahu@ds9a.nl
To: remco@virtu.nl
In-Reply-To: <Pine.LNX.4.58.0503092041400.17842@localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


nice solution but maybe challenging to get to work with braindead
windoz machines. 
My thinking is if you have to use windoz then you probably wanna hide
everything from them - which may require kernel hacking (I think it is
worth it ;->).


cheers,
jamal

On Wed, 2005-03-09 at 15:01, Remco van Mook wrote:
> I've been toying with the suggestion to do something with routing table 0 to
> accomplish this, and I can report it works, standard 2.6.10 kernel. Here's how
> I did it:
> 
> Assuming a linux system, connected to a local network 172.16.0.0/24, own
> address 172.16.0.13, 'ppp' ip address to be assigned to a system that has
> ip address 172.16.0.4
> 
> On the box that establishes the PPP connection:
> 1) establish ppp connection, get IP address, say 192.168.0.2
> 2) ip route del local 192.168.0.2
> 3) ip route add 192.168.0.2 via 172.16.0.4
> 
> On the other box, 172.16.0.4:
> 
> 1) ip addr add 192.168.0.2 dev eth0
> 2) ip route add 0/0 via 172.16.0.13
> 
> I didn't bother assigning the IP address for the other box dynamically; that
> might still pose a challenge - outside the scope of netdev IMHO.
> 
> Optionally you might want to SNAT outbound traffic on the PPP interface to
> enforce the correct IP address. Of course the solution doesn't actually
> 'bridge' the traffic, you get another visible hop, but the effect is almost
> the same.
> 
> Kind regards,
> 
> Remco van Mook
> 
