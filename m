From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: nft 0.4, crash on list
Date: Sun, 22 Mar 2015 00:32:51 +0200
Message-ID: <fded527361344541342afa2478b5ca9a@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>, Pablo <pablo@netfilter.org>,
	Kaber <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36770 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbbCUWlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 18:41:18 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 285C248021B
	for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 00:32:52 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

Just attempted to use nft, and got a bit strange crash (but sure it is 
possible i am using it wrong way)
Table that was inserted there:

FIBERNET-NAT ~ # cat /etc/nft.cfg
#!/sbin/nft -f
table mangle {
         chain output            {
                 type route hook output priority -150;
                 meta mark set ip daddr map {
                         1.1.1.1/32 : 1
                 }
         }
}


FIBERNET-NAT ~ # nft --debug all list table mangle
Entering state 0
Reducing stack by rule 1 (line 544):
-> $$ = nterm input (: )
Stack now 0
Entering state 1
Reading a token: --accepting rule at line 261 ("list")
Next token is token "list" (: )
Shifting token "list" (: )
Entering state 19
Reading a token: --accepting rule at line 515 (" ")
--accepting rule at line 234 ("table")
Next token is token "table" (: )
Shifting token "table" (: )
Entering state 63
Reading a token: --accepting rule at line 515 (" ")
--(end of buffer or a NUL)
--accepting rule at line 486 ("mangle")
Next token is token "string" (: )
Reducing stack by rule 113 (line 1052):
-> $$ = nterm family_spec (: )
Stack now 0 1 19 63
Entering state 34
Next token is token "string" (: )
Shifting token "string" (: )
Entering state 41
Reducing stack by rule 110 (line 1045):
    $1 = token "string" (: )
-> $$ = nterm identifier (: )
Stack now 0 1 19 63 34
Entering state 167
Reducing stack by rule 120 (line 1063):
    $1 = nterm family_spec (: )
    $2 = nterm identifier (: )
-> $$ = nterm table_spec (: )
Stack now 0 1 19 63
Entering state 250
Reducing stack by rule 45 (line 752):
    $1 = token "table" (: )
    $2 = nterm table_spec (: )
-> $$ = nterm list_cmd (: )
Stack now 0 1 19
Entering state 69
Reducing stack by rule 19 (line 636):
    $1 = token "list" (: )
    $2 = nterm list_cmd (: )
-> $$ = nterm base_cmd (: )
Stack now 0 1
Entering state 32
Reading a token: --(end of buffer or a NUL)
--EOF (start condition 0)
Now at end of input.
Shifting token "end of file" (: )
Entering state 165
Reducing stack by rule 13 (line 602):
    $1 = nterm base_cmd (: )
    $2 = token "end of file" (: )
<cmdline>:1:1-17: Evaluate
list table mangle
^^^^^^^^^^^^^^^^^


Stack now 0 1
Cleanup: popping nterm input (: )
----------------        ------------------
|  0000000020  |        | message length |
| 02576 | R--- |        |  type | flags  |
|  0000000003  |        | sequence number|
|  0000000000  |        |     port ID    |
----------------        ------------------
| 00 00 00 00  |        |  extra header  |
----------------        ------------------
----------------        ------------------
|  0000000032  |        | message length |
| 02570 | R-A- |        |  type | flags  |
|  0000000005  |        | sequence number|
|  0000000000  |        |     port ID    |
----------------        ------------------
| 02 00 00 00  |        |  extra header  |
|00011|--|00001|        |len |flags| type|
| 6d 61 6e 67  |        |      data      |       m a n g
| 6c 65 00 00  |        |      data      |       l e
----------------        ------------------
map0 mangle f
map0 mangle 0
----------------        ------------------
|  0000000044  |        | message length |
| 02573 | R-A- |        |  type | flags  |
|  0000000005  |        | sequence number|
|  0000000000  |        |     port ID    |
----------------        ------------------
| 02 00 00 00  |        |  extra header  |
|00011|--|00001|        |len |flags| type|
| 6d 61 6e 67  |        |      data      |       m a n g
| 6c 65 00 00  |        |      data      |       l e
|00009|--|00002|        |len |flags| type|
| 6d 61 70 30  |        |      data      |       m a p 0
| 00 61 6e 67  |        |      data      |        a n g
----------------        ------------------
----------------        ------------------
|  0000000020  |        | message length |
| 02564 | R--- |        |  type | flags  |
|  0000000005  |        | sequence number|
|  0000000000  |        |     port ID    |
----------------        ------------------
| 02 00 00 00  |        |  extra header  |
----------------        ------------------
----------------        ------------------
|  0000000020  |        | message length |
| 02567 | R--- |        |  type | flags  |
|  0000000005  |        | sequence number|
|  0000000000  |        |     port ID    |
----------------        ------------------
| 02 00 00 00  |        |  extra header  |
----------------        ------------------
ip mangle output 3
   [ payload load 1b @ network header + 9 => reg 1 ]
   [ cmp eq reg 1 0x00000006 ]
   [ payload load 2b @ transport header + 0 => reg 1 ]
   [ cmp eq reg 1 0x00005000 ]
   [ immediate reg 1 0x0100ff7f ]
   [ meta set priority with reg 1 ]

update network layer protocol context:
  link layer          : none
  network layer       : ip <-
  transport layer     : none

update transport layer protocol context:
  link layer          : none
  network layer       : ip
  transport layer     : tcp <-

ip mangle output 4 3
   [ payload load 4b @ network header + 16 => reg 1 ]
   [ lookup reg 1 set map0 dreg 1 ]
   [ meta set mark with reg 1 ]

Segmentation fault
