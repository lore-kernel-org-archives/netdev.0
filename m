From: Abhishek Gupta <abhishek@pal.ece.iisc.ernet.in>
Subject: Problem using HTB
Date: Fri, 1 Apr 2005 15:10:40 +0530 (IST)
Message-ID: <Pine.BSO.4.58.0504011240500.6284@pal.ece.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hello everybody                                                                                                                                                                                                           
I am working on a project related to QoS. I am using Linux's tc to                                           
configure my PC based router.                                                                                
My setup is as follows:-
                                                                                                                                                                                                                 
              eth0       eth1            eth0      eth0                                                      
PC-based server|----------|PC-based Router|---------|PC-Based Client                                                                      
                            (using tc)                                                                                                                                                                                  
* All my ethernet cards are on 100Mbps lan                                                                   
* Traffic generators being used:                                                                               
  > UDP: gen_send @ about 1Mbps                                                                                  
    (http://www.citi.umich.edu/projects/qbone/generator.html)                                                
* Kernel versions being used:-                                                                                 
  > At Router: linux-2.4.20                                                                                    
  > At Client and Server: Linux-2.4.7-10                                                                     
* iproute2 versions:-                                                                                          
  > At Router: iproute2-ss020116                                                                               
  > At Client and Server: iproute2-ss010824                                                                  
* Packets before leaving sever and client are being marked with DSCP bits                                      
  using Linux's tc option; Marking is done based on two-tuples: 
  destination ip address and port number                                                                                    
* At the Router, I have the following configuration(only related to HTB)                                       
  for eth0 and similar configuration exits for eth1 too: 

---Router Configuration Starts Here-----                                                                                                                                                                                  
DEV0='eth0'                                                                                                                                                                                                               
tc qdisc add dev $DEV0 parent 1: handle 2: htb default 30                                                    
tc class add dev $DEV0 parent 2: classid 2:1 htb rate 100kbit burst 100 \                                       
   ceil 100kbit                                                                                              
tc class add dev $DEV0 parent 2:1 classid 2:10 htb rate 60kbit burst 100 \                                      
   ceil 100kbit                                                                                              
tc class add dev $DEV0 parent 2:1 classid 2:20 htb rate 30kbit burst 60 \                                       
   ceil 100kbit                                                                                              
tc class add dev $DEV0 parent 2:1 classid 2:30 htb rate 10kbit burst 80 \                                       
   ceil 100kbit                                                                                                                                                                                                           
tc qdisc add dev $DEV0 parent 2:10 gred setup DPs 3 default 3 grio                                           
tc qdisc change dev $DEV0 parent 2:10 gred limit 185000 min 11394 \  
   max 11395 burst 100 avpkt 128 bandwidth 100kbit DP 1 probability 1 \                                         
   prio 1                                                                                                    
tc qdisc change dev $DEV0 parent 2:10 gred limit 17972 min 4748 max 9493 \                                      
   burst 50 avpkt 1000 bandwidth 100kbit DP 2 probability 0.01 prio 2                                        
tc qdisc change dev $DEV0 parent 2:10 gred limit 4368 min 1796 max 3582 \                                       
   burst 25 avpkt 1000 bandwidth 100kbit DP 3 probability 0.01 prio 2                                                                                                                                                     
tc qdisc add dev $DEV0 parent 2:20 gred setup DPs 2 default 2 grio                                           
tc qdisc change dev $DEV0 parent 2:20 gred limit 52480 min 11311 \                                              
   max 11312 burst 60 avpkt 256 bandwidth 100kbit DP 1 probability 1 \                                          
   prio 1                                                                                                    
tc qdisc change dev $DEV0 parent 2:20 gred limit 47184 min 5898 \                                               
   max 11796 burst 60 avpkt 1000 bandwidth 100kbit DP 2 probability 0.01 \                                      
   prio 2                                   
                                                                                                             
tc qdisc add dev $DEV0 parent 2:30 gred setup DPs 1 default 1 grio                                           
tc qdisc change dev $DEV0 parent 2:30 gred limit 15728 min 1966 \                                               
   max 3932 burst 80 avpkt 200 bandwidth 100kbit DP 1 probability 0.04 \                                        
   prio 1                                                                                                                                                                                                                 
-----Router Configuration Ends Here------                                                                                                                                                                                                                                                                                              
Now, the problem is that when I am sending packets from just one UDP                                         
source(at server), I am getting outbound bit rate at eth0(of Router) as 12kbps                                     
even though I have ceiled the corresponding HTB class to 100kbps; similar thing                                   
happens when I have two UDP sources(both at server).  So, even though                                        
I have configured for 100kbps, I am getting only 12kbps as the link speed. 
                                                                                                             
Please help me out.                                                                                                                                                                                                       
Abhishek         


=========================================================================
ABHISHEK GUPTA 
E-mail:abhishek_it_bhu@yahoo.co.in
=========================================================================
