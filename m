From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Route hash code comparison
Date: Tue, 20 May 2003 18:12:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16074.21513.492796.943255@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

Route hash code comparison on fairly loaded router at Uppsala Universitet.
Router is loaded both in terms of packet load but also in IP-flows from 
(tens) of thousands of users.

The hash table was modified to count linear search in the cache which was
printed with rtstat (in_search). Router has 32 k hash buckets which is where 
the GC starts. This point is choosen for hash algorithm comparison as well.

Old hash:
107694/41990 ==>  2.6 linear searches for a packet look-up at 32 k entries

New hash:
33334/38927  ==> 0.86 linear searches for a packet look-up at 32 k entries

The new hash have random keys but seems to be pretty consistent in term of 
hashing at least from observerations. No DoS experiments done.


[rstat: Table is edited] 

size       == route cache size
hit        == IN: total number of cache hits per sec
tot        == IN: total number of cache misses per sec
GC         == GC: garbage collection calls per sec
in_search  == HASH: input hash list search per sec


 Linux 2.5.66
 size   IN: hit     tot     GC       in_search
==============================================
 1467     39622    1255      0           80331 
 7034     38195    268       0           19382 
 9743     51429    129       0           32903 
11633     50069     91       0           40124 
13316     48456     83       0           41458 
14846     45883     75       0           47253 
16233     44672     65       0           52647 
17574     43786     65       0           57167 
18855     43227     61       0           61784 
20106     43341     59       0           65187 
21316     43389     57       0           68505 
22481     43386     55       0           73778 
23694     42748     58       0           77601 
24819     42549     54       0           83328 
26180     41474     65       0           82393 
27331     41754     53       0           90068 
28408     41626     50       0           94326 
29415     40731     47       0           97407 
30424     42193     47       0          102571 
31382     41313     46       0          102311 
32348     41990     46       0          107694 * Analys1
33524     42104     57     377          108611 
34527     42170     48     501          118257 
34148     44107     45     468          120707 
35196     43345     50     524          116961 
36064     42004     42     434          119295 
35868     41805     49     504          119121 
36838     42299     45     487          116961 

 Linux 2.5.66 with hash code from 2.5.69.
 size   IN: hit     tot     GC       in_search
==============================================
 6031     34776      0       0            7150 
 8517     38168    119       0            5455 
10395     38431     86       0            6501 
11954     37002     73       0            8972 
13546     37776     74       0           10742 
14948     38595     65       0           12585 
16406     37981     67       0           13827 
17802     38479     64       0           15437 
18984     38392     54       0           17684 
20155     37989     54       0           18733 
21210     39508     48       0           20084 
22466     40834     57       0           21299 
23622     39226     52       0           23221 
24836     40965     56       0           24183 
26157     39683     63       0           24764 
27291     40309     54       0           27793 
28417     38468     54       0           25867 
29358     39199     44       0           29093 
30302     39159     45       0           29722 
31477     38284     56       0           31246 
32449     38927     46       0           33334 * Analys2
33386     39031     44     308           31837 
34300     39432     42     457           35057 
34117     38106     48     522           33129 
35155     37887     48     519           32823 
36187     37222     48     516           31986 
36326     37125     50     539           33914 
37257     38814     44     465           35457 




Cheers.
						--ro
