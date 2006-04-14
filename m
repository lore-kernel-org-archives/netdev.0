From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [RFC] Geographical/regulatory information for ieee80211
Date: Thu, 13 Apr 2006 19:59:21 -0500
Message-ID: <443EF3E9.7050303@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:49864 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S965084AbWDNA7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 20:59:31 -0400
To: netdev@vger.kernel.org, jeffl@comix.santa-cruz.ca.us
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am planning on writing a new routine to be added to net/ieee80211/ieee80211_geo.c that will 
populate an ieee80211_geo object given a country code. The new routine will eliminate the need for 
each driver to do their own.

Finding the allowable channels, etc. for various countries has not been easy; however, Cisco 
(http://www.cisco.com/en/US/products/ps6305/products_configuration_guide_chapter09186a008059c96f.html) 
has what seems to be the most complete listing of country information. Neglecting any discussion of 
maximum power, I have been able to arrange the countries into the following groups:

Group         Countries                      b/g channels          a channels
============================================================================

1        Austria                             1-11                   36, 40, 48, 52

2        Australia, Brazil, Canada           1-11                   36, 40, 44, 48
          Cyprus, Czech Republic, Estonia                            52, 56, 60, 64
          Hong Kong, Ireland, Lithuania, Latvia                     149,153,157,161
          New Zealand, Philippines, Poland
          Slovenia, Slovak Republic
          United States

3        Belgium, Israel                      1-11                  36, 40, 44, 48
                                                                     52, 56, 60, 64

4        Israel Outdoors                      5-13                  36, 40, 44, 48
                                                                     52, 56, 60, 64

5        Switzerland and Liechtenstein        1-11                  36, 40, 44, 48
          France, Hungary, United States Low

6        China, Republic of Korea (1)         1-13                 149,153,157,161

7        Republic of Korea (2)                1-13                  36, 40, 44, 48
                                                                     52, 56, 60, 64
                                                                    100,104,108,112
                                                                    116,120,124
                                                                    149,153,157,161

8        Germany, Denmark, Spain, Finland     1-11                  36, 40, 44, 48
          Great Britain, Iceland, Italy                              52, 56, 60, 64
          Luxembourg, Netherlands, Norway                           104,108,112,116
          Portugal, Sweden                                          120,124,128,132
                                                                    140

9        Greece, India                        1-11

10       Indonesia, Malaysia, Thailand        1-13
          South Africa

11       Japan                                1-14 (14 is b only)   36, 40, 44, 48

12       Japan High                           1-14 (14 is b only)   36, 40, 44, 48
                                                                     52, 56, 60, 64

13       Singapore                            1-13                  36, 40, 44, 48
                                                                     52, 56, 60, 64
                                                                    149,153,157,161

14       Taiwan                               1-13                  56, 60, 64
                                                                    100,104
                                                                    149,153,157,161

Any countries not listed above will be placed in group 9 with b/g channels of 1-11 and no valid "a" 
channels.

Please tell me if I have (a) missed any countries, or (b) gotten them wrong. Once I have a 
"netdev-list approved" set, I will do some coding. I have noticed that not all the ipw2200 codes 
that are listed in Documentation/README.ipw2200 correspond to these groups. All of the differences 
are in the valid "a" channels.

Thanks to Jeff Liebermann (jeffl@comix.santa-cruz.ca.us) for helping me find some of the 
geographical/regulatory info on the Web.

Larry
