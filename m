From: Will Stephenson <wstephenson@kde.org>
Subject: Re: no carrier detection after resume from swsusp (8139too)
Date: Thu, 23 Feb 2006 10:20:51 +0100
Message-ID: <200602231020.52298.wstephenson@kde.org>
References: <200602212312.23903.nfilus@gmx.net>
	<200602221612.14631.nfilus@gmx.net>
	<1140621599.6269.10.camel@betsy.boston.ximian.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_05X/DqmPXdAZeMs"
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>
Return-path: <networkmanager-list-bounces@gnome.org>
To: networkmanager-list@gnome.org, James Ettle <jhe@phys.soton.ac.uk>
In-Reply-To: <1140621599.6269.10.camel@betsy.boston.ximian.com>
List-Unsubscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=unsubscribe>
List-Archive: <http://mail.gnome.org/archives/networkmanager-list>
List-Post: <mailto:networkmanager-list@gnome.org>
List-Help: <mailto:networkmanager-list-request@gnome.org?subject=help>
List-Subscribe: <http://mail.gnome.org/mailman/listinfo/networkmanager-list>,
	<mailto:networkmanager-list-request@gnome.org?subject=subscribe>
Sender: networkmanager-list-bounces@gnome.org
Errors-To: networkmanager-list-bounces@gnome.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_05X/DqmPXdAZeMs
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday 22 February 2006 16:19, Robert Love wrote:
> e100 or e1000?

8139cp here.  Seems to have picked up this behaviour since SL10.1beta2 or so, 
still in beta4.

See https://bugzilla.novell.com/show_bug.cgi?id=151892

> `carrier' returns EINVAL if the device is not UP.  It might be a bug in
> NM if the device is not UP after a resume.  What does `ifconfig eth1`
> show before and after a resume?

carrier is 1 before and after, eth0 is UP before and after, restarting NM 
doesn't help, nor does stopping NM, rmmod, modprobe, and starting NM.  

I didn't think it is NM related, as I could not configure the network by hand 
after resume.   However, I just switched my network config to SUSE 
traditional ifup+ifplugd (joys of flexibility), and although eth0 does not 
work on resume, rcnetwork restart fixes it, whereas when NM is in charge, 
this does not help.  So my understanding is NM is not the direct cause but is 
a contributing factor.

Will


--Boundary-00=_05X/DqmPXdAZeMs
Content-Type: text/plain; charset="iso-8859-15"; name="ifconfig.after.resume"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ifconfig.after.resume"

eth0      Link encap:Ethernet  HWaddr 00:02:3F:67:0A:E3  
          inet addr:169.254.137.164  Bcast:169.254.255.255  Mask:255.255.0.0
          inet6 addr: fe80::202:3fff:fe67:ae3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2769 errors:0 dropped:3144 overruns:0 frame:0
          TX packets:180 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:285833 (279.1 Kb)  TX bytes:14752 (14.4 Kb)
          Interrupt:10 Base address:0x2000 

eth1      Link encap:Ethernet  HWaddr 00:0C:F1:13:76:CB  
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:5 Memory:90000000-90000fff 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:277 errors:0 dropped:0 overruns:0 frame:0
          TX packets:277 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:21838 (21.3 Kb)  TX bytes:21838 (21.3 Kb)


--Boundary-00=_05X/DqmPXdAZeMs
Content-Type: text/plain; charset="iso-8859-15"; name="ifconfig.before.suspend"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="ifconfig.before.suspend"

eth0      Link encap:Ethernet  HWaddr 00:02:3F:67:0A:E3  
          inet addr:10.10.101.143  Bcast:10.10.255.255  Mask:255.255.0.0
          inet6 addr: 2001:780:101:a00:202:3fff:fe67:ae3/64 Scope:Global
          inet6 addr: fe80::202:3fff:fe67:ae3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2210 errors:0 dropped:0 overruns:0 frame:0
          TX packets:177 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:251842 (245.9 Kb)  TX bytes:14494 (14.1 Kb)
          Interrupt:10 Base address:0x2000 

eth1      Link encap:Ethernet  HWaddr 00:0C:F1:13:76:CB  
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Interrupt:5 Memory:90000000-90000fff 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:149 errors:0 dropped:0 overruns:0 frame:0
          TX packets:149 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:12784 (12.4 Kb)  TX bytes:12784 (12.4 Kb)


--Boundary-00=_05X/DqmPXdAZeMs
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NetworkManager-list mailing list
NetworkManager-list@gnome.org
http://mail.gnome.org/mailman/listinfo/networkmanager-list

--Boundary-00=_05X/DqmPXdAZeMs--
