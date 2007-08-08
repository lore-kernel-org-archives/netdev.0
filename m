From: ggrundstrom@neteffect.com
Subject: [ofa-general] [PATCH 0/14] nes: NetEffect 10Gb RNIC Driver
Date: Tue, 7 Aug 2007 19:22:14 -0500
Message-ID: <200708080022.l780ME9e004542@neteffect.com>
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

NetEffect is proud to announce the following series of patches which contain the source code for the NE020 10Gb RNIC adapter.  The driver is split into two components - a kernel driver module and a userspace library.

The code can also be found in the following git trees.
git.openfabrics.org/~glenn/libnes.git
git.openfabrics.org/~glenn/ofed_1_2.git
git.openfabrics.org/~glenn/ofascripts.git
git.openfabrics.org/~glenn/ofed_1_2_scripts.git


Requirements
============
* NE020 hardware
* RHEL4u4 or FC5
* OFED 1.2 GA
* OFED 1.2 version of MVAPICH2 
 
 
Known issues
============
* DAPL only works with 1 process per node due to lack of loopback
* MPI over DAPL must use MPI shared memory loopback
 
 
Plans for next release
======================
* Plan on adding verbs loopback to enable DAPL loopback
* Increase robustness and stability
 
 
What we tested
==============
The performance results are meant to be broadly representative. 
Results can vary depending on switches used, system configuration, OS used, etc.
 
Configuration notes:
All two node tests were performed back-to-back i.e. no switch Multinode
testing was performed using a high performance, low latency cut-through switch.
 
Platform: CentOS x86_64
 
1.    cbench rotate latency and bandwidth using mvapich2 over OFA verbs:
 
      Rotate Latency: 6.67 us
      Rotate Bandwidth: 9.3 Gpbs
 
2.    OSU bandwidth and latency tests using mvapich2 over OFA verbs:
 
      OSU Latency: 6.74 us
      OSU Bi-Bandwidth: 14.4 Gbps
 
3.    Perftest (rdma_bw Uni-dir/Bi-dir and rdma_lat)
 
      RDMA Bandwidth Uni-directional:  8.9  Gpbs
      RDMA Bandwidth Bi-directional : 15.09 Gpbs
      RDMA Latency                  :  5.95 us
 
4.    NIC Testing
 
      Iperf 4 stream Bi-directional test
 
Iperf -c <Srvr IP Addr> -d -M -N -i 4 -P 4 (Jumbo packets enabled) --> 10.76 Gbps
      
NetPerf
netperf -H <Srvr IP Addr> -T1,1 -t TCP_STREAM -l 60 -C -c (Jumbo packets enabled) --> 6.2 Gbps
 
 


Thanks,
Glenn.
