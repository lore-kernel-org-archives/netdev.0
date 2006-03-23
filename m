From: Mark Butler <butlerm@middle.net>
Subject: Re: Re: [iproute2] IPoIB link layer address bug
Date: Thu, 23 Mar 2006 11:10:16 -0700
Message-ID: <4422E488.3060509@middle.net>
References: <Pine.LNX.4.61.0603161707360.23670@jlentini-linux.nane.netapp.com>
	<20060321155617.3ae419b2@localhost.localdomain>
	<20060322013046.GA29127@obsidianresearch.com>
	<Pine.LNX.4.61.0603231155401.23670@jlentini-linux.nane.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1895615210=="
Cc: netdev@vger.kernel.org,
	openib-general <openib-general@openib.org>,
	Stephen Hemminger <shemminger@osdl.org>
Return-path: <openib-general-bounces@openib.org>
To: James Lentini <jlentini@netapp.com>
In-Reply-To: <Pine.LNX.4.61.0603231155401.23670@jlentini-linux.nane.netapp.com>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--===============1895615210==
Content-Type: multipart/alternative;
	boundary="------------020206050700090503040706"

This is a multi-part message in MIME format.
--------------020206050700090503040706
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

James Lentini wrote:

>On Tue, 21 Mar 2006, Jason Gunthorpe wrote:
>
>  
>
>>On Tue, Mar 21, 2006 at 03:56:17PM -0800, Stephen Hemminger wrote:
>>
>>    
>>
>>>Okay, but there are number of other places in iproute2 that call 
>>>ll_addr_a2n() with ifr.ifr_hwaddr.sa_data. And that is 14 bytes.  
>>>If you want to fix those it will be harder since it would increase 
>>>the sizeof(struct sockaddr) and potentially break compatibility.
>>>      
>>>
>>Maybe the best thing is to upgrade ip (and or netlink?) to use 
>>netlink messages instead of ioctls for the remaining problematic 
>>operations. Since netlink already supports an arbitary length hwaddr 
>>there should be no compatability problem.
>>
>>Just browsing I see usages of SIOCSIFHWBROADCAST, SIOCSIFHWADDR, 
>>SIOCADDMULTI, SIOCDELMULTI and SIOCGIFHWADDR that use a struct 
>>ifreq..
>>
>>I know SIOCGIFHWADDR can be done over netlink, but I'm not too 
>>familiar with the others..
>>    
>>
>
>Making ip neighbor work with IPoIB address is what I'm interested in 
>now.
>
>As you and Jason point out there are a lot of places where ifreqs are 
>used and hence options that will not support IPoIB addresses.
>
>  
>
The sockaddr union is at the end of struct ifreq.  Couldn't the union 
sockaddr members be changed to sockaddr_storage, and the SIOCxxxx 
encoded size bits be changed?  dev_ifsioc() would just need to mask out 
(or substitute) the size bits before the switch statement.

 - Mark




--------------020206050700090503040706
Content-Type: text/html; charset=us-ascii
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta content="text/html;charset=ISO-8859-1" http-equiv="Content-Type">
  <title></title>
</head>
<body bgcolor="#ffffff" text="#000000">
James Lentini wrote:<br>
<blockquote
 cite="midPine.LNX.4.61.0603231155401.23670@jlentini-linux.nane.netapp.com"
 type="cite">
  <pre wrap="">On Tue, 21 Mar 2006, Jason Gunthorpe wrote:

  </pre>
  <blockquote type="cite">
    <pre wrap="">On Tue, Mar 21, 2006 at 03:56:17PM -0800, Stephen Hemminger wrote:

    </pre>
    <blockquote type="cite">
      <pre wrap="">Okay, but there are number of other places in iproute2 that call 
ll_addr_a2n() with ifr.ifr_hwaddr.sa_data. And that is 14 bytes.  
If you want to fix those it will be harder since it would increase 
the sizeof(struct sockaddr) and potentially break compatibility.
      </pre>
    </blockquote>
    <pre wrap="">Maybe the best thing is to upgrade ip (and or netlink?) to use 
netlink messages instead of ioctls for the remaining problematic 
operations. Since netlink already supports an arbitary length hwaddr 
there should be no compatability problem.

Just browsing I see usages of SIOCSIFHWBROADCAST, SIOCSIFHWADDR, 
SIOCADDMULTI, SIOCDELMULTI and SIOCGIFHWADDR that use a struct 
ifreq..

I know SIOCGIFHWADDR can be done over netlink, but I'm not too 
familiar with the others..
    </pre>
  </blockquote>
  <pre wrap=""><!---->
Making ip neighbor work with IPoIB address is what I'm interested in 
now.

As you and Jason point out there are a lot of places where ifreqs are 
used and hence options that will not support IPoIB addresses.

  </pre>
</blockquote>
The sockaddr union is at the end of struct ifreq.&nbsp; Couldn't the union
sockaddr members be changed to sockaddr_storage, and the SIOCxxxx
encoded size bits be changed?&nbsp; dev_ifsioc() would just need to mask out
(or substitute) the size bits before the switch statement.<br>
<br>
&nbsp;- Mark<br>
<br>
<br>
<br>
</body>
</html>

--------------020206050700090503040706--

--===============1895615210==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


--===============1895615210==--
