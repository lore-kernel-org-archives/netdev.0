From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Known problems with TCP window size on 2.6.7?
Date: Wed, 27 Oct 2004 13:06:17 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027110617.GA28757@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,
   are there some known problems with 2.6.7 and TCP window growing up over limits?  
usermap is running 2.6.7-bk1, regata1 is running some AIX5.

   It seems that at startup they do not agree on using window scaling, yet Linux grows
window above 64KB, throwing away high window size bit, and very bad things happen after 
that - AIX is confused that our window shrunk (which is illegal, I'd say) and switches 
to some strange "1 packet every 200ms" mode.

   In this state connection stays until it is closed (which takes over 10 hours
with transfer we want to perform).  Our window never goes back from 449 anywhere (and
values depend on tranfered data; sometime it ends up with window size 328 and others;
I saw different values in range 200-500).

   I was using this kernel since middle of June, and it worked flawlessly until
about three weeks ago when large SQL transfer started needing over 10 hours instead 
of less than 1 minute they were taking just day before.


12:44:17.564459 IP regata1.1526 > usermap.52501: P 588189:588844(655) ack 43805 win 65535
12:44:17.568496 IP usermap.52501 > regata1.1526: P 43805:43853(48) ack 588844 win 63040
12:44:17.646162 IP regata1.1526 > usermap.52501: . ack 43853 win 65535
12:44:17.706182 IP regata1.1526 > usermap.52501: P 588844:589508(664) ack 43853 win 65535
12:44:17.710367 IP usermap.52501 > regata1.1526: P 43853:43901(48) ack 589508 win 63040
12:44:17.846308 IP regata1.1526 > usermap.52501: . ack 43901 win 65535
12:44:17.893726 IP regata1.1526 > usermap.52501: P 589508:590203(695) ack 43901 win 65535
12:44:17.897917 IP usermap.52501 > regata1.1526: P 43901:43949(48) ack 590203 win 64395
                                                                                  ^^^^^
12:44:18.046237 IP regata1.1526 > usermap.52501: . ack 43949 win 65535
12:44:18.080419 IP regata1.1526 > usermap.52501: P 590203:590980(777) ack 43949 win 65535
12:44:18.084746 IP usermap.52501 > regata1.1526: P 43949:43997(48) ack 590980 win 449
                                                                                  ^^^
12:44:18.246438 IP regata1.1526 > usermap.52501: . 590980:591429(449) ack 43997 win 65535
12:44:18.288637 IP usermap.52501 > regata1.1526: . ack 591429 win 449
12:44:18.288863 IP regata1.1526 > usermap.52501: P 591429:591670(241) ack 43997 win 65535
12:44:18.289094 IP usermap.52501 > regata1.1526: . ack 591670 win 449
12:44:18.292995 IP usermap.52501 > regata1.1526: P 43997:44045(48) ack 591670 win 449
12:44:18.446430 IP regata1.1526 > usermap.52501: . 591670:592119(449) ack 44045 win 65535
12:44:18.488626 IP usermap.52501 > regata1.1526: . ack 592119 win 449


						Thanks,
							Petr Vandrovec
