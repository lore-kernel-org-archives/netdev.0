From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: user space multicast routing interface
Date: Sun, 25 Jan 2004 13:35:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF96C6EB7E.C8369F79-ON88256E26.0075342A@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	Boundary="0__=07BBE4B5DFE6B2BA8f9e8a93df938690918c07BBE4B5DFE6B2BA"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Lamparter <equinox@diac24.net>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B5DFE6B2BA8f9e8a93df938690918c07BBE4B5DFE6B2BA
Content-type: text/plain; charset=US-ASCII





For an IGMPv3 querier, which doesn't have to be a multicast router,
all you really need to do is create a raw socket with proto IPPROTO_IGMP
and join the "all multicast routers group" (224.0.0.22) on the interface
you
care about. Send the query to 224.0.0.1 and do a recvfrom() for the
response.

                        +-DLS


David Lamparter <equinox@diac24.net>@oss.sgi.com on 01/25/2004 09:37:13 AM

Sent by:    netdev-bounce@oss.sgi.com


To:    netdev@oss.sgi.com
cc:
Subject:    user space multicast routing interface



Hi,

[...skip down if you don't like long "sorry for mailing" mails ;)]

first of all, please excuse me mailing to netdev for a not directly
kernel related Linux networking question - i didn't find any other place
where i could ask...

I recently started playing around with multicast routing for educational
purposes; multicast client software was easy to write, ran well and
there were lots of docs about setsockopts etc.

Continuing on my way, I'm trying to write a simple IGMP querier now, but
even getting started turns out to be pretty difficult here, almost no
docs exist (well, the FreeBSD manpage...). I tried everything coming to
my mind, but i wasn't even able to get to receiving all IGMP packets on
an interface.

[...stop skipping here]

so, 2 questions:
* what sockopts are neccessary to get all IGMP packets (all multicast
groups) on a raw socket? (MRT_INIT / MRT_ADD_VIF should do it, but it
doesn't work)
* is it possible to bind VIFs to interface indices? in ipmr.c / struct
vifctl there is no ifindex parameter (real interface, not vif)

as you can see from the 2nd question, i at least tried reading the
kernel source (2.6.1), but i don't know the stack so its difficult to
understand...

David Lamparter



Appended: testing code for IGMP

no error messages on 2.6.1, interface has
<BROADCAST,MULTICAST,ALLMULTI,UP> flags while code is running, vif shows
up under /proc/net/ip_mr_vif:
Interface      BytesIn  PktsIn  BytesOut PktsOut Flags Local    Remote
  1 eth0              0       0         0       0 08000 160216AC 00000000

<cut includes for space issues>

#define E(x) if (x) printf ("error doing %s: %d [%s]\n", \
         #x, errno, strerror (errno));
int main(int argc, char **argv)
{
         int mrouter_s4; int p = 1; struct vifctl vc;

         mrouter_s4 = socket(AF_INET, SOCK_RAW, IPPROTO_IGMP);
         E(setsockopt(mrouter_s4, IPPROTO_IP, MRT_INIT,
                 (void *)&p, sizeof(p)));

         memset(&vc, 0, sizeof(vc));
         vc.vifc_vifi = vc.vifc_threshold = 1;
         vc.vifc_rate_limit = 4096;
         vc.vifc_lcl_addr.s_addr = inet_addr(argv[1]);
         E(setsockopt(mrouter_s4, IPPROTO_IP, MRT_ADD_VIF,
                 (void *)&vc, sizeof(vc)));

         while(1) {
                 char buf[4096]; struct sockaddr_in sender;
                 socklen_t sendsize = sizeof(sender);
                 int size = recvfrom(mrouter_s4, buf, 4096, 0,
                         (struct sockaddr *) &sender, &sendsize);
                 printf ("got %d from %s\n", size,
                         inet_ntoa(sender.sin_addr));
         }
}






--0__=07BBE4B5DFE6B2BA8f9e8a93df938690918c07BBE4B5DFE6B2BA
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>For an IGMPv3 querier, which doesn't have to be a multicast router,<br>
all you really need to do is create a raw socket with proto IPPROTO_IGMP<br>
and join the &quot;all multicast routers group&quot; (224.0.0.22) on the interface you<br>
care about. Send the query to 224.0.0.1 and do a recvfrom() for the<br>
response.<br>
<br>
				+-DLS<br>
<br>

<p><font size="2" color="#800080">Sent by:	netdev-bounce@oss.sgi.com</font>
<p><font size="2" color="#800080">To:	</font><font size="2">netdev@oss.sgi.com</font><br>
<font size="2" color="#800080">cc:	 </font><br>
<font size="2" color="#800080">Subject:	</font><font size="2">user space multicast routing interface</font><br>
<br>
<br>
<br>
<tt>Hi,<br>
</tt><br>
<tt>[...skip down if you don't like long &quot;sorry for mailing&quot; mails ;)]<br>
</tt><br>
<tt>first of all, please excuse me mailing to netdev for a not directly<br>
kernel related Linux networking question - i didn't find any other place<br>
where i could ask...<br>
</tt><br>
<tt>I recently started playing around with multicast routing for educational<br>
purposes; multicast client software was easy to write, ran well and<br>
there were lots of docs about setsockopts etc.<br>
</tt><br>
<tt>Continuing on my way, I'm trying to write a simple IGMP querier now, but<br>
even getting started turns out to be pretty difficult here, almost no<br>
docs exist (well, the FreeBSD manpage...). I tried everything coming to<br>
my mind, but i wasn't even able to get to receiving all IGMP packets on<br>
an interface.<br>
</tt><br>
<tt>[...stop skipping here]<br>
</tt><br>
<tt>so, 2 questions:<br>
* what sockopts are neccessary to get all IGMP packets (all multicast<br>
groups) on a raw socket? (MRT_INIT / MRT_ADD_VIF should do it, but it<br>
doesn't work)<br>
* is it possible to bind VIFs to interface indices? in ipmr.c / struct<br>
vifctl there is no ifindex parameter (real interface, not vif)<br>
</tt><br>
<tt>as you can see from the 2nd question, i at least tried reading the<br>
kernel source (2.6.1), but i don't know the stack so its difficult to<br>
understand...<br>
</tt><br>
<tt>David Lamparter<br>
</tt><br>
<br>
<br>
<tt>Appended: testing code for IGMP<br>
</tt><br>
<tt>no error messages on 2.6.1, interface has<br>
&lt;BROADCAST,MULTICAST,ALLMULTI,UP&gt; flags while code is running, vif shows<br>
up under /proc/net/ip_mr_vif:<br>
Interface &nbsp; &nbsp; &nbsp;BytesIn &nbsp;PktsIn &nbsp;BytesOut PktsOut Flags Local &nbsp; &nbsp;Remote</tt>
<ul><tt>1 eth0 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;0 &nbsp; &nbsp; &nbsp; 0 &nbsp; &nbsp; &nbsp; &nbsp; 0 &nbsp; &nbsp; &nbsp; 0 08000 160216AC 00000000<br>
</tt></ul>
<tt>&lt;cut includes for space issues&gt;<br>
</tt><br>
<tt>#define E(x) if (x) printf (&quot;error doing %s: %d [%s]\n&quot;, \<br>
#x, errno, strerror (errno));</tt><br>
<tt>int main(int argc, char **argv)<br>
{</tt>
<ul>
<ul>
<ul><tt>int mrouter_s4; int p = 1; struct vifctl vc;<br>
</tt><br>
<tt>mrouter_s4 = socket(AF_INET, SOCK_RAW, IPPROTO_IGMP);<br>
E(setsockopt(mrouter_s4, IPPROTO_IP, MRT_INIT,</tt>
<ul>
<ul>
<ul><tt>(void *)&amp;p, sizeof(p)));<br>
</tt></ul>
</ul>
</ul>
<tt>memset(&amp;vc, 0, sizeof(vc));<br>
vc.vifc_vifi = vc.vifc_threshold = 1;<br>
vc.vifc_rate_limit = 4096;<br>
vc.vifc_lcl_addr.s_addr = inet_addr(argv[1]);<br>
E(setsockopt(mrouter_s4, IPPROTO_IP, MRT_ADD_VIF,</tt>
<ul>
<ul>
<ul><tt>(void *)&amp;vc, sizeof(vc)));<br>
</tt></ul>
</ul>
</ul>
<tt>while(1) {<br>
char buf[4096]; struct sockaddr_in sender;<br>
socklen_t sendsize = sizeof(sender);<br>
int size = recvfrom(mrouter_s4, buf, 4096, 0,</tt>
<ul>
<ul>
<ul><tt>(struct sockaddr *) &amp;sender, &amp;sendsize);<br>
printf (&quot;got %d from %s\n&quot;, size,</tt></ul>
</ul>
</ul>
<tt>inet_ntoa(sender.sin_addr));<br>
}</tt></ul>
</ul>
</ul>
<tt>}<br>
</tt><br>
<br>
<br>
<br>
<br>
<br>
</body></html>
--0__=07BBE4B5DFE6B2BA8f9e8a93df938690918c07BBE4B5DFE6B2BA--
