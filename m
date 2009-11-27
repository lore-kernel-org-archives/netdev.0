From: Asdo <asdo@shiftmail.org>
Subject: Re: TCP sockets stalling - help! (long)
Date: Fri, 27 Nov 2009 13:56:13 +0100
Message-ID: <4B0FCC6D.3050003@shiftmail.org>
References: <4B0CB1B8.8030402@shiftmail.org> <20091126233302.42be8780@houba>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3949664984720259570=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>
To: Frederic Leroy <fredo@starox.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <20091126233302.42be8780@houba>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--===============3949664984720259570==
Content-type: multipart/alternative;
	boundary="Boundary_(ID_vr+HEWKTlefyZYpQJ5V+mA)"

This is a multi-part message in MIME format.

--Boundary_(ID_vr+HEWKTlefyZYpQJ5V+mA)
Content-type: text/plain; format=flowed; charset=UTF-8
Content-transfer-encoding: QUOTED-PRINTABLE

Frederic Leroy wrote:
> Le Wed, 25 Nov 2009 05:25:28 +0100,
> Asdo <asdo@shiftmail.org> a =C3=A9crit :
>
>  =20
>> Hi netdev and e1000 people,
>>
>> I have a weird problem here.
>> [...]
>>    =20
>
> I have the same kind of problem at home. I can't copy big files ove=
r
> ssh unless I limit the rate ( ssh -l 8000 ... )
> After reading your mail, I make some quick tests ( see below).
>
> Results in short :
> - netcat always work.
> - ssh stalls, nearly immediately.
>  =20
Good God it's true then!

I think I have an idea for why Netcat works while scp doesn't:
probably SCP pushing data requires replies from the application layer=
=20
(the 60 bytes I was telling about for SFTP) while netcat doesnt, it j=
ust=20
needs the Acks to keep pushing data.

Still if I am right, with Netcat you might end up with a corrupted fi=
le=20
on the other side (shorter). Or maybe not, depending on how exactly t=
he=20
bug is made. Could you check this? Filesize and md5sum.

I think I just reproduced the bug on another machine, different hardw=
are=20
(Supermicro mainboard), same Ubuntu, same kernel, same integrated Int=
el=20
network card. It just takes 5 hours or so for me to trigger.

Do you have Intel network card, with e1000e driver on SG? (see lsmod)=
=20
(sorry I was wrong before, it's e1000e in my case not e1000) Otherwis=
e=20
it's probably the TCP layer...

Would you paste here your lspci and lsmod?

Thank you



--Boundary_(ID_vr+HEWKTlefyZYpQJ5V+mA)--


--===============3949664984720259570==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
--===============3949664984720259570==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel

--===============3949664984720259570==--
