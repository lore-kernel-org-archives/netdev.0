From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Crazy TCP bug (keepalive flood?) in 2.6.32?
Date: Sat, 16 Jan 2010 16:12:04 +0200
Message-ID: <201001161612.04747.denys@visp.net.lb>
References: <200912261703.49067.denys@visp.net.lb> <alpine.DEB.2.00.1001111459340.14108@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:32936 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab0APOLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2010 09:11:17 -0500
In-Reply-To: <alpine.DEB.2.00.1001111459340.14108@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 January 2010 15:02:34 you wrote:
> On Sat, 26 Dec 2009, Denys Fedoryshchenko wrote:
> > Few more dumps. I notice:
> > 1)Ack always equal 1
> > 2)It is usually first segment of data sent (?)
> >
> > Maybe some value not initialised properly?
> >
> >
> Can you see if the RTO lower bound is violated (I added some printing of
> vars there too already now if it turns out to be something):
> 
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 65b8ebf..d84469f 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -327,6 +327,22 @@ static void do_pmtu_discovery(struct sock *sk, struct
Hi, i'm very sorry for delay. Just having problem with Lebanese ISP's (u pay 
20k for 20mbit, u get 20% packetloss at peak time, and they say it is normal).

I did test, here is some things from dmesg
[  396.496765] lower bound violation: 0                                                                                                                                          
[  396.496833] rto: 200 (0 >> 3 + 0, 4) time: 96496 sent: 96496 pen: 1 96696 
rem: 200                                                                                            
[  399.442640] lower bound violation: 0                                                                                                                                          
[  399.442721] rto: 200 (0 >> 3 + 0, 16) time: 99442 sent: 99421 pen: 1 102621 
rem: 179                                                                                          
[  399.444802] lower bound violation: 0                                                                                                                                          
[  399.444881] rto: 200 (0 >> 3 + 0, 10) time: 99444 sent: 99233 pen: 1 102433 
rem: 0                                                                                            
[  399.446444] lower bound violation: 0                                                                                                                                          
[  399.446521] rto: 200 (0 >> 3 + 0, 15) time: 99446 sent: 99421 pen: 1 99621 
rem: 175                                                                                           
[  399.539751] lower bound violation: 0                                                                                                                                          
[  399.539832] rto: 200 (0 >> 3 + 0, 7) time: 99539 sent: 99496 pen: 1 102696 
rem: 157                                                                                           
[  399.539964] rto: 200 (0 >> 3 + 0, 6) time: 99539 sent: 99496 pen: 1 99696 
rem: 157                                                                                            
[  399.540650] rto: 200 (0 >> 3 + 0, 5) time: 99540 sent: 99496 pen: 1 99696 
rem: 156                                                                                            
[  402.445674] __ratelimit: 2 callbacks suppressed                                                                                                                               
[  402.445756] lower bound violation: 0                                                                                                                                          
[  402.445833] rto: 200 (0 >> 3 + 0, 18) time: 102445 sent: 102421 pen: 1 
105621 rem: 176                                                                                        
[  402.445958] lower bound violation: 0                                                                                                                                          
[  402.446026] rto: 200 (0 >> 3 + 0, 13) time: 102445 sent: 102244 pen: 1 
105444 rem: 0                                                                                          
[  402.446150] lower bound violation: 0                                                                                                                                          
[  402.446217] rto: 200 (0 >> 3 + 0, 17) time: 102446 sent: 102421 pen: 1 
102621 rem: 175                                                                                        
[  402.742463] lower bound violation: 0                                                                                                                                          
[  402.742544] rto: 200 (0 >> 3 + 0, 8) time: 102742 sent: 102496 pen: 1 
105696 rem: 0                                                                                           
[  402.743567] lower bound violation: 0                                                                                                                                          
[  402.744361] rto: 200 (0 >> 3 + 0, 8) time: 102744 sent: 102742 pen: 1 
103142 rem: 198                                                                                         
[  402.744478] lower bound violation: 0                                                                                                                                          
[  402.744545] rto: 200 (0 >> 3 + 0, 7) time: 102744 sent: 102742 pen: 1 
102942 rem: 198                                                                                         
[  405.446861] lower bound violation: 0                                                                                                                                          
[  405.446943] rto: 200 (0 >> 3 + 0, 20) time: 105446 sent: 105421 pen: 1 
108621 rem: 175                                                                                        
[  405.447075] lower bound violation: 0                                                                                                                                          
[  405.447142] rto: 200 (0 >> 3 + 0, 16) time: 105446 sent: 105246 pen: 1 
108446 rem: 0                                                                                          
[  405.447265] lower bound violation: 0                                                                                                                                          
[  405.447332] rto: 200 (0 >> 3 + 0, 19) time: 105446 sent: 105421 pen: 1 
105621 rem: 175                                                                                        
[  405.759226] lower bound violation: 0                                                                                                                                          
[  405.759307] rto: 200 (0 >> 3 + 0, 10) time: 105759 sent: 105742 pen: 1 
108942 rem: 183                                                                                        
[  405.763529] rto: 200 (0 >> 3 + 0, 9) time: 105763 sent: 105742 pen: 1 
105942 rem: 179                                                                                         
[  405.764344] rto: 200 (0 >> 3 + 0, 8) time: 105764 sent: 105742 pen: 1 
105942 rem: 178                                                                                         
[  408.450964] __ratelimit: 2 callbacks suppressed                                                                                                                               
[  408.451045] lower bound violation: 0                                                                                                                                          
[  408.451121] rto: 200 (0 >> 3 + 0, 22) time: 108450 sent: 108421 pen: 1 
111621 rem: 171                                                                                        
[  408.451246] lower bound violation: 0                                                                                                                                          
[  408.451314] rto: 200 (0 >> 3 + 0, 19) time: 108450 sent: 108246 pen: 1 
111446 rem: 0                                                                                          
[  408.451437] lower bound violation: 0                                                                                                                                          
[  408.451504] rto: 200 (0 >> 3 + 0, 21) time: 108450 sent: 108421 pen: 1 
108621 rem: 171                                                                                        
[  408.792229] lower bound violation: 0                                                                                                                                          
[  408.792307] rto: 200 (0 >> 3 + 0, 11) time: 108792 sent: 108742 pen: 1 
111942 rem: 150                                                                                        
[  408.792821] lower bound violation: 0                                                                                                                                          
[  408.792897] rto: 200 (0 >> 3 + 0, 10) time: 108792 sent: 108742 pen: 1 
108942 rem: 150                                                                                        
[  408.793033] lower bound violation: 0                                                                                                                                          
[  408.793109] rto: 200 (0 >> 3 + 0, 9) time: 108793 sent: 108742 pen: 1 
108943 rem: 149                                                                                         
[  411.478006] lower bound violation: 0                                                                                                                                          
[  411.478088] rto: 200 (0 >> 3 + 0, 24) time: 111478 sent: 111421 pen: 1 
114621 rem: 143                                                                                        
[  411.478220] lower bound violation: 0                                                                                                                                          
[  411.478287] rto: 200 (0 >> 3 + 0, 22) time: 111478 sent: 111250 pen: 1 
114450 rem: 0                                                                                          
[  411.478411] lower bound violation: 0                                                                                                                                          
[  411.478478] rto: 200 (0 >> 3 + 0, 23) time: 111478 sent: 111421 pen: 1 
111621 rem: 143                                                                                        
[  411.804382] lower bound violation: 0                                                                                                                                          
[  411.804464] rto: 200 (0 >> 3 + 0, 12) time: 111804 sent: 111742 pen: 1 
114942 rem: 138                                                                                        
[  411.804598] rto: 200 (0 >> 3 + 0, 11) time: 111804 sent: 111742 pen: 1 
111942 rem: 138                                                                                        
[  414.498996] __ratelimit: 1 callbacks suppressed                                                                                                                               
[  414.499080] lower bound violation: 0                                                                                                                                          
[  414.499160] rto: 200 (0 >> 3 + 0, 26) time: 114498 sent: 114421 pen: 1 
117621 rem: 123                                                                                        
[  414.513129] lower bound violation: 0                                                                                                                                          
[  414.513207] rto: 200 (0 >> 3 + 0, 25) time: 114513 sent: 114278 pen: 1 
117478 rem: 0                                                                                          
[  414.513344] lower bound violation: 0                                                                                                                                          
[  414.513412] rto: 200 (0 >> 3 + 0, 25) time: 114513 sent: 114421 pen: 1 
114621 rem: 108                                                                                        
[  414.784717] lower bound violation: 0                                                                                                                                          
[  414.784799] rto: 200 (0 >> 3 + 0, 14) time: 114784 sent: 114742 pen: 1 
117942 rem: 158                                                                                        
[  414.786072] lower bound violation: 0                                                                                                                                          
[  414.786152] rto: 200 (0 >> 3 + 0, 13) time: 114786 sent: 114742 pen: 1 
114942 rem: 156                                                                                        
[  417.515995] lower bound violation: 0                                                                                                                                          
[  417.516077] rto: 200 (0 >> 3 + 0, 28) time: 117516 sent: 117421 pen: 1 
120621 rem: 105                                                                                        
[  417.516213] lower bound violation: 0                                                                                                                                          
[  417.516289] rto: 200 (0 >> 3 + 0, 28) time: 117516 sent: 117313 pen: 1 
120513 rem: 0                                                                                          
[  417.516413] lower bound violation: 0                                                                                                                                          
[  417.516481] rto: 200 (0 >> 3 + 0, 27) time: 117516 sent: 117421 pen: 1 
117621 rem: 105                                                                                        
[  417.803533] lower bound violation: 0                                                                                                                                          
[  417.803615] rto: 200 (0 >> 3 + 0, 16) time: 117803 sent: 117742 pen: 1 
120942 rem: 139                                                                                        
[  417.803745] lower bound violation: 0                                                                                                                                          
[  417.803812] rto: 200 (0 >> 3 + 0, 15) time: 117803 sent: 117742 pen: 1 
117942 rem: 139                                                                                        
[  417.803930] rto: 200 (0 >> 3 + 0, 14) time: 117803 sent: 117742 pen: 1 
117942 rem: 139                                                                                        
[  420.556115] __ratelimit: 1 callbacks suppressed                                                                                                                               
[  420.556198] lower bound violation: 0                                                                                                                                          
[  420.556274] rto: 200 (0 >> 3 + 0, 30) time: 120556 sent: 120421 pen: 1 
123621 rem: 65                                                                                         
[  420.556399] lower bound violation: 0                                                                                                                                          
[  420.556466] rto: 200 (0 >> 3 + 0, 31) time: 120556 sent: 120316 pen: 1 
123516 rem: 0                                                                                          
[  420.556591] lower bound violation: 0                                                                                                                                          
[  420.556659] rto: 200 (0 >> 3 + 0, 29) time: 120556 sent: 120421 pen: 1 
120621 rem: 65                                                                                         
[  420.965666] lower bound violation: 0                                                                                                                                          
[  420.965749] rto: 200 (0 >> 3 + 0, 17) time: 120965 sent: 120742 pen: 1 
123942 rem: 0                                                                                          
[  420.967717] lower bound violation: 0                                                                                                                                          
[  420.967796] rto: 200 (0 >> 3 + 0, 17) time: 120967 sent: 120965 pen: 1 
121365 rem: 198                                                                                        
[  420.972139] lower bound violation: 0                                                                                                                                          
[  420.972216] rto: 200 (0 >> 3 + 0, 16) time: 120972 sent: 120965 pen: 1 
121165 rem: 193                                                                                        
[  423.564843] lower bound violation: 0                                                                                                                                          
[  423.564924] rto: 200 (0 >> 3 + 0, 32) time: 123564 sent: 123421 pen: 1 
126621 rem: 57                                                                                         
[  423.565062] lower bound violation: 0                                                                                                                                          
[  423.565130] rto: 200 (0 >> 3 + 0, 34) time: 123565 sent: 123356 pen: 1 
126556 rem: 0                                                                                          
[  423.565254] lower bound violation: 0                                                                                                                                          
[  423.565322] rto: 200 (0 >> 3 + 0, 31) time: 123565 sent: 123421 pen: 1 
123622 rem: 56                                                                                         
[  424.001854] lower bound violation: 0                                                                                                                                          
[  424.001936] rto: 200 (0 >> 3 + 0, 19) time: 124001 sent: 123965 pen: 1 
127165 rem: 164                                                                                        
[  424.005665] rto: 200 (0 >> 3 + 0, 18) time: 124005 sent: 123965 pen: 1 
124166 rem: 160                                                                                        
[  424.007636] rto: 200 (0 >> 3 + 0, 17) time: 124007 sent: 123965 pen: 1 
124165 rem: 158                                                                                        
[  426.580172] __ratelimit: 2 callbacks suppressed                                                                                                                               
[  426.580254] lower bound violation: 0                                                                                                                                          
[  426.580337] rto: 200 (0 >> 3 + 0, 34) time: 126580 sent: 126421 pen: 1 
129621 rem: 41                                                                                         
[  426.580456] lower bound violation: 0                                                                                                                                          
[  426.580524] rto: 200 (0 >> 3 + 0, 37) time: 126580 sent: 126365 pen: 1 
129565 rem: 0                                                                                          
[  426.580647] lower bound violation: 0                                                                                                                                          
[  426.580715] rto: 200 (0 >> 3 + 0, 33) time: 126580 sent: 126421 pen: 1 
126621 rem: 41                                                                                         
[  427.210363] lower bound violation: 0                                                                                                                                          
[  427.210443] rto: 200 (0 >> 3 + 0, 20) time: 127210 sent: 126965 pen: 1 
130165 rem: 0                                                                                          
[  427.210587] lower bound violation: 0                                                                                                                                          
[  427.210654] rto: 200 (0 >> 3 + 0, 20) time: 127210 sent: 127210 pen: 1 
127610 rem: 200                                                                                        
[  427.210770] lower bound violation: 0                                                                                                                                          
[  427.210837] rto: 200 (0 >> 3 + 0, 19) time: 127210 sent: 127210 pen: 1 
127410 rem: 200                                                                                        
[  429.586539] lower bound violation: 0                                                                                                                                          
[  429.586628] rto: 200 (0 >> 3 + 0, 36) time: 129586 sent: 129421 pen: 1 
132621 rem: 35                                                                                         
[  429.588735] lower bound violation: 0                                                                                                                                          
[  429.588814] rto: 200 (0 >> 3 + 0, 40) time: 129588 sent: 129380 pen: 1 
132580 rem: 0                                                                                          
[  429.589880] lower bound violation: 0                                                                                                                                          
[  429.589957] rto: 200 (0 >> 3 + 0, 35) time: 129589 sent: 129421 pen: 1 
129621 rem: 32                                                                                         
[  430.231164] lower bound violation: 0                                                                                                                                          
[  430.231246] rto: 200 (0 >> 3 + 0, 22) time: 130231 sent: 130210 pen: 1 
133410 rem: 179                                                                                        
[  430.253497] rto: 200 (0 >> 3 + 0, 21) time: 130253 sent: 130210 pen: 1 
130410 rem: 157                                                                                        
[  432.600005] __ratelimit: 1 callbacks suppressed                                                                                                                               
[  432.600087] lower bound violation: 0                                                                                                                                          
[  432.600164] rto: 200 (0 >> 3 + 0, 38) time: 132600 sent: 132421 pen: 1 
135621 rem: 21                                                                                         
[  432.601516] lower bound violation: 0                                                                                                                                          
[  432.601593] rto: 200 (0 >> 3 + 0, 43) time: 132601 sent: 132388 pen: 1 
135588 rem: 0                                                                                          
[  432.601729] lower bound violation: 0                                                                                                                                          
[  432.601796] rto: 200 (0 >> 3 + 0, 37) time: 132601 sent: 132421 pen: 1 
132621 rem: 20                                                                                         
[  433.292095] lower bound violation: 0                                                                                                                                          
[  433.292177] rto: 200 (0 >> 3 + 0, 24) time: 133292 sent: 133210 pen: 1 
136410 rem: 118                                                                                        
[  433.292308] lower bound violation: 0                                                                                                                                          
[  433.292375] rto: 200 (0 >> 3 + 0, 23) time: 133292 sent: 133210 pen: 1 
133410 rem: 118                                                                                        
[  433.292491] lower bound violation: 0                                                                                                                                          
[  433.292558] rto: 200 (0 >> 3 + 0, 22) time: 133292 sent: 133210 pen: 1 
133410 rem: 118                                                                                        
[  435.624429] lower bound violation: 0                                                                                                                                          
[  435.624512] rto: 200 (0 >> 3 + 0, 40) time: 135624 sent: 135421 pen: 1 
138621 rem: 0                                                                                          
[  435.624649] lower bound violation: 0                                                                                                                                          
[  435.624717] rto: 200 (0 >> 3 + 0, 46) time: 135624 sent: 135401 pen: 1 
138601 rem: 0                                                                                          
[  435.625410] lower bound violation: 0                                                                                                                                          
[  435.625410] rto: 200 (0 >> 3 + 0, 40) time: 135624 sent: 135624 pen: 1 
136024 rem: 200                                                                                        
[  436.455058] lower bound violation: 0                                                                                                                                          
[  436.455140] rto: 200 (0 >> 3 + 0, 25) time: 136455 sent: 136210 pen: 1 
139410 rem: 0                                                                                          
[  436.455279] rto: 200 (0 >> 3 + 0, 25) time: 136455 sent: 136455 pen: 1 
136855 rem: 200                                                                                        
[  436.455397] rto: 200 (0 >> 3 + 0, 24) time: 136455 sent: 136455 pen: 1 
136655 rem: 200                                                                                        
[  439.507877] __ratelimit: 2 callbacks suppressed                                                                                                                               
[  439.507959] lower bound violation: 0                                                                                                                                          
[  439.508037] rto: 200 (0 >> 3 + 0, 27) time: 139507 sent: 139455 pen: 1 
142655 rem: 148                                                                                        
[  439.508161] lower bound violation: 0                                                                                                                                          
[  439.508228] rto: 200 (0 >> 3 + 0, 26) time: 139507 sent: 139455 pen: 1 
139655 rem: 148                                                                                        
[  442.507756] lower bound violation: 0                                                                                                                                          
[  442.507838] rto: 200 (0 >> 3 + 0, 29) time: 142507 sent: 142455 pen: 1 
145655 rem: 148                                                                                        
[  442.507969] lower bound violation: 0                                                                                                                                          
[  442.508035] rto: 200 (0 >> 3 + 0, 28) time: 142507 sent: 142455 pen: 1 
142655 rem: 148                                                                                        
[  442.508152] lower bound violation: 0                                                                                                                                          
[  442.508219] rto: 200 (0 >> 3 + 0, 27) time: 142507 sent: 142455 pen: 1 
142655 rem: 148                                                                                        
[  445.498049] lower bound violation: 0                                                                                                                                          
[  445.498130] rto: 200 (0 >> 3 + 0, 30) time: 145498 sent: 145455 pen: 1 
148655 rem: 157                                                                                        
[  445.499105] lower bound violation: 0                                                                                                                                          
[  445.499194] rto: 200 (0 >> 3 + 0, 29) time: 145499 sent: 145455 pen: 1 
145655 rem: 156                                                                                        
[  445.501524] lower bound violation: 0                                                                                                                                          
[  445.501600] rto: 200 (0 >> 3 + 0, 28) time: 145501 sent: 145455 pen: 1 
145655 rem: 154                                                                                        
[  448.678590] lower bound violation: 0                                                                                                                                          
[  448.678671] rto: 200 (0 >> 3 + 0, 31) time: 148678 sent: 148455 pen: 1 
151655 rem: 0                                                                                          
[  448.678808] lower bound violation: 0                                                                                                                                          
[  448.678876] rto: 200 (0 >> 3 + 0, 31) time: 148678 sent: 148678 pen: 1 
149078 rem: 200                                                                                        
[  451.716905] lower bound violation: 0                                                                                                                                          
[  451.716987] rto: 200 (0 >> 3 + 0, 34) time: 151716 sent: 151678 pen: 1 
154878 rem: 162                                                                                        
[  451.763041] lower bound violation: 0                                                                                                                                          
[  451.763121] rto: 200 (0 >> 3 + 0, 33) time: 151763 sent: 151678 pen: 1 
151878 rem: 115                                                                                        
[  451.763252] lower bound violation: 0                                                                                                                                          
[  451.763320] rto: 200 (0 >> 3 + 0, 32) time: 151763 sent: 151678 pen: 1 
151878 rem: 115                                                                                        
[  454.732396] lower bound violation: 0                                                                                                                                          
[  454.732478] rto: 200 (0 >> 3 + 0, 35) time: 154732 sent: 154678 pen: 1 
157878 rem: 146                                                                                        
[  454.736990] lower bound violation: 0                                                                                                                                          
[  454.737072] rto: 200 (0 >> 3 + 0, 34) time: 154737 sent: 154678 pen: 1 
154878 rem: 141                                                                                        
[  454.738128] lower bound violation: 0                                                                                                                                          
[  454.738206] rto: 200 (0 >> 3 + 0, 33) time: 154738 sent: 154678 pen: 1 
154878 rem: 140                                                                                        
[  457.894010] lower bound violation: 0                                                                                                                                          
[  457.894098] rto: 200 (0 >> 3 + 0, 36) time: 157894 sent: 157678 pen: 1 
160878 rem: 0                                                                                          
[  457.913672] lower bound violation: 0                                                                                                                                          
[  457.913751] rto: 200 (0 >> 3 + 0, 36) time: 157913 sent: 157894 pen: 1 
158294 rem: 181                                                                                        
[  457.913883] lower bound violation: 0                                                                                                                                          
[  457.913950] rto: 200 (0 >> 3 + 0, 35) time: 157913 sent: 157894 pen: 1 
158094 rem: 181                                                                                        
[  460.932992] lower bound violation: 0                                                                                                                                          
[  460.933073] rto: 200 (0 >> 3 + 0, 38) time: 160932 sent: 160894 pen: 1 
164094 rem: 162                                                                                        
[  460.933206] lower bound violation: 0                                                                                                                                          
[  460.933273] rto: 200 (0 >> 3 + 0, 37) time: 160932 sent: 160894 pen: 1 
161094 rem: 162                                                                                        
[  460.933390] lower bound violation: 0                                                                                                                                          
[  460.933457] rto: 200 (0 >> 3 + 0, 36) time: 160932 sent: 160894 pen: 1 
161094 rem: 162                                                                                        
[  463.928470] lower bound violation: 0                                                                                                                                          
[  463.928551] rto: 200 (0 >> 3 + 0, 39) time: 163928 sent: 163894 pen: 1 
167094 rem: 166                                                                                        
[  466.953674] lower bound violation: 0                                                                                                                                          
[  466.953755] rto: 200 (0 >> 3 + 0, 42) time: 166953 sent: 166894 pen: 1 
170094 rem: 141                                                                                        
[  466.953887] lower bound violation: 0                                                                                                                                          
[  466.953954] rto: 200 (0 >> 3 + 0, 41) time: 166953 sent: 166894 pen: 1 
167094 rem: 141                                                                                        
[  470.112498] lower bound violation: 0                                                                                                                                          
[  470.112580] rto: 200 (0 >> 3 + 0, 44) time: 170112 sent: 169894 pen: 1 
173094 rem: 0                                                                                          
[  470.127286] lower bound violation: 0                                                                                                                                          
[  470.127364] rto: 200 (0 >> 3 + 0, 44) time: 170127 sent: 170112 pen: 1 
170512 rem: 185                                                                                        
[  473.167817] lower bound violation: 0                                                                                                                                          
[  473.167899] rto: 200 (0 >> 3 + 0, 47) time: 173167 sent: 173112 pen: 1 
176312 rem: 145                                                                                        
[  473.168030] lower bound violation: 0                                                                                                                                          
[  473.168098] rto: 200 (0 >> 3 + 0, 46) time: 173168 sent: 173112 pen: 1 
173313 rem: 144                                                                                        
[  473.169413] lower bound violation: 0                                                                                                                                          
[  473.169491] rto: 200 (0 >> 3 + 0, 45) time: 173169 sent: 173112 pen: 1 
173312 rem: 143                                                                                        
[  522.630573] lower bound violation: 0                                                                                                                                          
[  522.630655] rto: 200 (0 >> 3 + 0, 0) time: 222630 sent: 222630 pen: 1 
228630 rem: 200                                                                                         
[  627.844099] lower bound violation: 0                                                                                                                                          
[  627.844176] rto: 200 (0 >> 3 + 0, 8) time: 327844 sent: 324830 pen: 1 
427230 rem: 0                                                                                           
[  630.848249] lower bound violation: 0                                                                                                                                          
[  630.848333] rto: 200 (0 >> 3 + 0, 11) time: 330848 sent: 330644 pen: 1 
333844 rem: 0                                                                                          
[  735.859328] lower bound violation: 0                                                                                                                                          
[  735.859388] rto: 200 (0 >> 3 + 0, 19) time: 435859 sent: 432848 pen: 1 
535248 rem: 0                                                                                          
[  738.864261] lower bound violation: 0                                                                                                                                          
[  738.864322] rto: 200 (0 >> 3 + 0, 22) time: 438864 sent: 438659 pen: 1 
441859 rem: 0                                                                                          
[  738.865358] lower bound violation: 0                                                                                                                                          
[  738.865415] rto: 200 (0 >> 3 + 0, 22) time: 438865 sent: 438864 pen: 1 
439264 rem: 199                                                                                        
[  741.864947] lower bound violation: 0                                                                                                                                          
[  741.865007] rto: 200 (0 >> 3 + 0, 25) time: 441864 sent: 441864 pen: 1 
445064 rem: 200                                                                                        
[  741.867651] lower bound violation: 0                                                                                                                                          
[  741.867709] rto: 200 (0 >> 3 + 0, 24) time: 441867 sent: 441864 pen: 1 
442065 rem: 197                                                                                        
[  741.867821] lower bound violation: 0                                                                                                                                          
[  741.867875] rto: 200 (0 >> 3 + 0, 23) time: 441867 sent: 441864 pen: 1 
442064 rem: 197                                                                                        
[  744.874165] lower bound violation: 0                                                                                                                                          
[  744.874225] rto: 200 (0 >> 3 + 0, 26) time: 444874 sent: 444864 pen: 1 
448064 rem: 190                                                                                        
[  744.874340] lower bound violation: 0                                                                                                                                          
[  744.874388] rto: 200 (0 >> 3 + 0, 25) time: 444874 sent: 444864 pen: 1 
445064 rem: 190                                                                                        
[  744.874486] lower bound violation: 0                                                                                                                                          
[  744.874535] rto: 200 (0 >> 3 + 0, 24) time: 444874 sent: 444864 pen: 1 
445064 rem: 190                                                                                        
[  747.874311] lower bound violation: 0                                                                                                                                          
[  747.874373] rto: 200 (0 >> 3 + 0, 27) time: 447874 sent: 447864 pen: 1 
451064 rem: 190                                                                                        
[  747.874474] lower bound violation: 0                                                                                                                                          
[  747.874523] rto: 200 (0 >> 3 + 0, 26) time: 447874 sent: 447864 pen: 1 
448064 rem: 190                                                                                        
[  747.874628] lower bound violation: 0                                                                                                                                          
[  747.874677] rto: 200 (0 >> 3 + 0, 25) time: 447874 sent: 447864 pen: 1 
448064 rem: 190                                                                                        
[  750.870109] lower bound violation: 0                                                                                                                                          
[  750.870170] rto: 200 (0 >> 3 + 0, 28) time: 450870 sent: 450864 pen: 1 
454064 rem: 194                                                                                        
[  750.870281] lower bound violation: 0                                                                                                                                          
[  750.870330] rto: 200 (0 >> 3 + 0, 27) time: 450870 sent: 450864 pen: 1 
451064 rem: 194                                                                                        
[  750.870435] lower bound violation: 0                                                                                                                                          
[  750.870484] rto: 200 (0 >> 3 + 0, 26) time: 450870 sent: 450864 pen: 1 
451064 rem: 194                                                                                        
[  753.882598] lower bound violation: 0                                                                                                                                          
[  753.882661] rto: 200 (0 >> 3 + 0, 29) time: 453882 sent: 453864 pen: 1 
457064 rem: 182                                                                                        
[  753.882779] lower bound violation: 0                                                                                                                                          
[  753.882842] rto: 200 (0 >> 3 + 0, 28) time: 453882 sent: 453864 pen: 1 
454064 rem: 182                                                                                        
[  753.882975] lower bound violation: 0                                                                                                                                          
[  753.883050] rto: 200 (0 >> 3 + 0, 27) time: 453883 sent: 453864 pen: 1 
454064 rem: 181                                                                                        
[  756.874204] lower bound violation: 0                                                                                                                                          
[  756.874265] rto: 200 (0 >> 3 + 0, 30) time: 456874 sent: 456864 pen: 1 
460064 rem: 190                                                                                        
[  756.874376] lower bound violation: 0                                                                                                                                          
[  756.874424] rto: 200 (0 >> 3 + 0, 29) time: 456874 sent: 456864 pen: 1 
457064 rem: 190                                                                                        
[  756.874527] lower bound violation: 0                                                                                                                                          
[  756.874576] rto: 200 (0 >> 3 + 0, 28) time: 456874 sent: 456864 pen: 1 
457064 rem: 190                                                                                        
[  759.891416] lower bound violation: 0                                                                                                                                          
[  759.891480] rto: 200 (0 >> 3 + 0, 31) time: 459891 sent: 459864 pen: 1 
463064 rem: 173                                                                                        
[  759.891591] lower bound violation: 0                                                                                                                                          
[  759.891647] rto: 200 (0 >> 3 + 0, 30) time: 459891 sent: 459864 pen: 1 
460064 rem: 173                                                                                        
[  759.891746] lower bound violation: 0                                                                                                                                          
[  759.892390] rto: 200 (0 >> 3 + 0, 29) time: 459891 sent: 459864 pen: 1 
460064 rem: 173                                                                                        
[  763.066046] lower bound violation: 0                                                                                                                                          
[  763.066106] rto: 200 (0 >> 3 + 0, 32) time: 463066 sent: 462864 pen: 1 
466064 rem: 0                                                                                          
[  763.066224] lower bound violation: 0                                                                                                                                          
[  763.066273] rto: 200 (0 >> 3 + 0, 32) time: 463066 sent: 463066 pen: 1 
463466 rem: 200                                                                                        
[  763.066371] lower bound violation: 0                                                                                                                                          
[  763.066419] rto: 200 (0 >> 3 + 0, 31) time: 463066 sent: 463066 pen: 1 
463266 rem: 200                                                                                        
[  766.065427] lower bound violation: 0                                                                                                                                          
[  766.065501] rto: 200 (0 >> 3 + 0, 33) time: 466065 sent: 464466 pen: 1 
466066 rem: 0                                                                                          
[  766.069012] lower bound violation: 0                                                                                                                                          
[  766.069070] rto: 200 (0 >> 3 + 0, 33) time: 466068 sent: 466065 pen: 1 
466465 rem: 197                                                                                        
[  766.069184] lower bound violation: 0                                                                                                                                          
[  766.069242] rto: 200 (0 >> 3 + 0, 32) time: 466069 sent: 466065 pen: 1 
466266 rem: 196                                                                                        
[  769.077813] lower bound violation: 0                                                                                                                                          
[  769.077873] rto: 200 (0 >> 3 + 0, 35) time: 469077 sent: 469065 pen: 1 
472265 rem: 188                                                                                        
[  769.077985] lower bound violation: 0                                                                                                                                          
[  769.078043] rto: 200 (0 >> 3 + 0, 34) time: 469078 sent: 469065 pen: 1 
469265 rem: 187                                                                                        
[  772.078686] lower bound violation: 0                                                                                                                                          
[  772.078746] rto: 200 (0 >> 3 + 0, 37) time: 472078 sent: 472065 pen: 1 
475265 rem: 187                                                                                        
[  772.078859] lower bound violation: 0                                                                                                                                          
[  772.078907] rto: 200 (0 >> 3 + 0, 36) time: 472078 sent: 472065 pen: 1 
472265 rem: 187                                                                                        
[  772.079674] lower bound violation: 0                                                                                                                                          
[  772.079731] rto: 200 (0 >> 3 + 0, 35) time: 472079 sent: 472065 pen: 1 
472265 rem: 186                                                                                        
[  775.269432] lower bound violation: 0                                                                                                                                          
[  775.269494] rto: 200 (0 >> 3 + 0, 38) time: 475269 sent: 475065 pen: 1 
478265 rem: 0                                                                                          
[  775.270671] lower bound violation: 0                                                                                                                                          
[  775.270733] rto: 200 (0 >> 3 + 0, 38) time: 475270 sent: 475269 pen: 1 
475669 rem: 199                                                                                        
[  775.270848] lower bound violation: 0                                                                                                                                          
[  775.270897] rto: 200 (0 >> 3 + 0, 37) time: 475270 sent: 475269 pen: 1 
475469 rem: 199                                                                                        
[  778.277343] lower bound violation: 0                                                                                                                                          
[  778.277404] rto: 200 (0 >> 3 + 0, 40) time: 478277 sent: 478269 pen: 1 
481469 rem: 192                                                                                        
[  778.277536] lower bound violation: 0                                                                                                                                          
[  778.277602] rto: 200 (0 >> 3 + 0, 39) time: 478277 sent: 478269 pen: 1 
478469 rem: 192                                                                                        
[  778.277722] lower bound violation: 0                                                                                                                                          
[  778.277778] rto: 200 (0 >> 3 + 0, 38) time: 478277 sent: 478269 pen: 1 
478469 rem: 192                                                                                        
[  781.272677] lower bound violation: 0                                                                                                                                          
[  781.272737] rto: 200 (0 >> 3 + 0, 41) time: 481272 sent: 481269 pen: 1 
484469 rem: 197                                                                                        
[  781.272850] lower bound violation: 0                                                                                                                                          
[  781.272898] rto: 200 (0 >> 3 + 0, 40) time: 481272 sent: 481269 pen: 1 
481469 rem: 197                                                                                        
[  784.274886] lower bound violation: 0                                                                                                                                          
[  784.274946] rto: 200 (0 >> 3 + 0, 43) time: 484274 sent: 484269 pen: 1 
487469 rem: 195                                                                                        
[  784.275064] lower bound violation: 0                                                                                                                                          
[  784.275112] rto: 200 (0 >> 3 + 0, 42) time: 484275 sent: 484269 pen: 1 
484470 rem: 194                                                                                        
[  784.275212] lower bound violation: 0                                                                                                                                          
[  784.275260] rto: 200 (0 >> 3 + 0, 41) time: 484275 sent: 484269 pen: 1 
484469 rem: 194                                                                                        
[  787.274753] lower bound violation: 0                                                                                                                                          
[  787.274814] rto: 200 (0 >> 3 + 0, 44) time: 487274 sent: 487269 pen: 1 
490469 rem: 195                                                                                        
[  787.276560] lower bound violation: 0                                                                                                                                          
[  787.276615] rto: 200 (0 >> 3 + 0, 43) time: 487276 sent: 487269 pen: 1 
487469 rem: 193                                                                                        
[  787.276725] lower bound violation: 0                                                                                                                                          
[  787.276781] rto: 200 (0 >> 3 + 0, 42) time: 487276 sent: 487269 pen: 1 
487469 rem: 193                                                                                        
[  790.488206] lower bound violation: 0                                                                                                                                          
[  790.488262] rto: 200 (0 >> 3 + 0, 45) time: 490488 sent: 490269 pen: 1 
493469 rem: 0                                                                                          
[  790.488375] lower bound violation: 0                                                                                                                                          
[  790.488425] rto: 200 (0 >> 3 + 0, 45) time: 490488 sent: 490488 pen: 1 
490888 rem: 200                                                                                        
[  790.488523] lower bound violation: 0                                                                                                                                          
[  790.488570] rto: 200 (0 >> 3 + 0, 44) time: 490488 sent: 490488 pen: 1 
490688 rem: 200                                                                                        
[  793.498782] lower bound violation: 0                                                                                                                                          
[  793.498842] rto: 200 (0 >> 3 + 0, 47) time: 493498 sent: 493488 pen: 1 
496688 rem: 190                                                                                        
[  793.498953] lower bound violation: 0                                                                                                                                          
[  793.499007] rto: 200 (0 >> 3 + 0, 46) time: 493498 sent: 493488 pen: 1 
493688 rem: 190                                                                                        
[  793.499118] lower bound violation: 0                                                                                                                                          
[  793.499172] rto: 200 (0 >> 3 + 0, 45) time: 493499 sent: 493488 pen: 1 
493689 rem: 189                                                                                        
[  796.499231] lower bound violation: 0                                                                                                                                          
[  796.499296] rto: 200 (0 >> 3 + 0, 48) time: 496499 sent: 496488 pen: 1 
499688 rem: 189                                                                                        
[  796.499414] lower bound violation: 0                                                                                                                                          
[  796.499463] rto: 200 (0 >> 3 + 0, 47) time: 496499 sent: 496488 pen: 1 
496688 rem: 189                                                                                        
[  796.500131] lower bound violation: 0                                                                                                                                          
[  796.500185] rto: 200 (0 >> 3 + 0, 46) time: 496500 sent: 496488 pen: 1 
496688 rem: 188                                                                                        
[  799.709974] lower bound violation: 0                                                                                                                                          
[  799.710036] rto: 200 (0 >> 3 + 0, 49) time: 499710 sent: 499488 pen: 1 
502688 rem: 0                                                                                          
[  799.711369] lower bound violation: 0                                                                                                                                          
[  799.711428] rto: 200 (0 >> 3 + 0, 49) time: 499711 sent: 499710 pen: 1 
500110 rem: 199                                                                                        
[  799.711547] lower bound violation: 0                                                                                                                                          
[  799.711602] rto: 200 (0 >> 3 + 0, 48) time: 499711 sent: 499710 pen: 1 
499910 rem: 199                                                                                        
[  802.718498] lower bound violation: 0                                                                                                                                          
[  802.718560] rto: 200 (0 >> 3 + 0, 51) time: 502718 sent: 502710 pen: 1 
505910 rem: 192                                                                                        
[  802.718689] lower bound violation: 0                                                                                                                                          
[  802.718753] rto: 200 (0 >> 3 + 0, 50) time: 502718 sent: 502710 pen: 1 
502910 rem: 192                                                                                        
[  802.718869] lower bound violation: 0                                                                                                                                          
[  802.718921] rto: 200 (0 >> 3 + 0, 49) time: 502718 sent: 502710 pen: 1 
502910 rem: 192                                                                                        
[  805.714361] lower bound violation: 0                                                                                                                                          
[  805.714422] rto: 200 (0 >> 3 + 0, 52) time: 505714 sent: 505710 pen: 1 
508910 rem: 196                                                                                        
[  805.714533] lower bound violation: 0                                                                                                                                          
[  805.714590] rto: 200 (0 >> 3 + 0, 51) time: 505714 sent: 505710 pen: 1 
505910 rem: 196                                                                                        
[  805.714688] lower bound violation: 0                                                                                                                                          
[  805.714736] rto: 200 (0 >> 3 + 0, 50) time: 505714 sent: 505710 pen: 1 
505910 rem: 196                                                                                        
[  808.715859] lower bound violation: 0                                                                                                                                          
[  808.715919] rto: 200 (0 >> 3 + 0, 53) time: 508715 sent: 508710 pen: 1 
511910 rem: 195                                                                                        
[  808.716030] lower bound violation: 0                                                                                                                                          
[  808.716086] rto: 200 (0 >> 3 + 0, 52) time: 508715 sent: 508710 pen: 1 
508910 rem: 195                                                                                        
[  808.716185] lower bound violation: 0                                                                                                                                          
[  808.716233] rto: 200 (0 >> 3 + 0, 51) time: 508715 sent: 508710 pen: 1 
508910 rem: 195                                                                                        
[  811.723842] lower bound violation: 0                                                                                                                                          
[  811.723903] rto: 200 (0 >> 3 + 0, 54) time: 511723 sent: 511710 pen: 1 
514910 rem: 187                                                                                        
[  811.724015] lower bound violation: 0
[  811.724073] rto: 200 (0 >> 3 + 0, 53) time: 511724 sent: 511710 pen: 1 
511910 rem: 186
[  811.724185] lower bound violation: 0
[  811.724234] rto: 200 (0 >> 3 + 0, 52) time: 511724 sent: 511710 pen: 1 
511910 rem: 186
[  814.717152] lower bound violation: 0
[  814.717212] rto: 200 (0 >> 3 + 0, 55) time: 514717 sent: 514710 pen: 1 
517910 rem: 193
[  814.717325] lower bound violation: 0
[  814.717373] rto: 200 (0 >> 3 + 0, 54) time: 514717 sent: 514710 pen: 1 
514910 rem: 193
[  814.718354] lower bound violation: 0
[  814.718407] rto: 200 (0 >> 3 + 0, 53) time: 514718 sent: 514710 pen: 1 
514910 rem: 192
[  817.907863] lower bound violation: 0
[  817.907923] rto: 200 (0 >> 3 + 0, 56) time: 517907 sent: 517710 pen: 1 
520910 rem: 3
[  817.912287] lower bound violation: 0
[  817.912346] rto: 200 (0 >> 3 + 0, 56) time: 517912 sent: 517911 pen: 1 
518311 rem: 199
[  817.912456] lower bound violation: 0
[  817.912511] rto: 200 (0 >> 3 + 0, 55) time: 517912 sent: 517911 pen: 1 
518111 rem: 199
[  820.941479] lower bound violation: 0
[  820.941539] rto: 200 (0 >> 3 + 0, 58) time: 520941 sent: 520911 pen: 1 
524111 rem: 170
[  820.941671] lower bound violation: 0
[  820.941733] rto: 200 (0 >> 3 + 0, 57) time: 520941 sent: 520911 pen: 1 
521111 rem: 170
[  820.941846] lower bound violation: 0
[  820.941895] rto: 200 (0 >> 3 + 0, 56) time: 520941 sent: 520911 pen: 1 
521111 rem: 170
[  824.121180] lower bound violation: 0
[  824.121242] rto: 200 (0 >> 3 + 0, 59) time: 524121 sent: 523911 pen: 1 
527111 rem: 0
[  824.121346] lower bound violation: 0
[  824.122108] rto: 200 (0 >> 3 + 0, 59) time: 524121 sent: 524121 pen: 1 
524521 rem: 200
[  824.123817] lower bound violation: 0
[  824.123887] rto: 200 (0 >> 3 + 0, 58) time: 524123 sent: 524121 pen: 1 
524322 rem: 198
[  827.122286] lower bound violation: 0
[  827.122347] rto: 200 (0 >> 3 + 0, 61) time: 527122 sent: 527121 pen: 1 
530321 rem: 199
[  827.124167] lower bound violation: 0
[  827.124223] rto: 200 (0 >> 3 + 0, 60) time: 527124 sent: 527121 pen: 1 
527321 rem: 197
[  827.124332] lower bound violation: 0
[  827.124389] rto: 200 (0 >> 3 + 0, 59) time: 527124 sent: 527121 pen: 1 
527321 rem: 197
[  830.124556] lower bound violation: 0
[  830.124617] rto: 200 (0 >> 3 + 0, 62) time: 530124 sent: 530121 pen: 1 
533321 rem: 197
[  830.124729] lower bound violation: 0
[  830.124777] rto: 200 (0 >> 3 + 0, 61) time: 530124 sent: 530121 pen: 1 
530321 rem: 197
[  830.124874] lower bound violation: 0
[  830.124922] rto: 200 (0 >> 3 + 0, 60) time: 530124 sent: 530121 pen: 1 
530321 rem: 197
